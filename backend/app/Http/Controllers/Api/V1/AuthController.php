<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\LoginRequest;
use App\Http\Requests\Api\V1\RegisterRequest;
use App\Http\Resources\V1\UserResource;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    private function updateUserLocation(User $user, Request $request): void
    {
        // Skip if user already has location set
        if ($user->location) {
            return;
        }

        try {
            $ip = $request->ip();
            // Use ip-api.com (free, no API key needed, 45 req/min limit)
            $response = Http::timeout(3)->get("http://ip-api.com/json/{$ip}?fields=city,country");
            
            if ($response->successful()) {
                $data = $response->json();
                if (isset($data['country'])) {
                    $location = $data['country'];
                }
                $user->update(['location' => $location]);
            }
        } catch (\Exception $e) {
            // Silently fail - location is not critical
        }
    }

    public function register(RegisterRequest $request)
    {
        $user = User::create([
            'name' => $request->validated('name'),
            'email' => $request->validated('email'),
            'password' => $request->validated('password'),
        ]);

        $this->updateUserLocation($user, $request);

        $token = $user->createToken('api')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => new UserResource($user->fresh()),
        ], 201);
    }

    public function login(LoginRequest $request)
    {
        $user = User::where('email', $request->validated('email'))->first();

        if (! $user || ! Hash::check($request->validated('password'), $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Invalid credentials.'],
            ]);
        }

        $this->updateUserLocation($user, $request);

        $token = $user->createToken('api')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => new UserResource($user->fresh()),
        ]);
    }

    public function workosCallback(Request $request)
    {
        $request->validate([
            'code' => 'required|string',
        ]);

        // Exchange the authorization code for user info
        $response = Http::withoutVerifying()
            ->withHeaders([
                'Authorization' => 'Bearer ' . config('services.workos.api_key'),
            ])
            ->post('https://api.workos.com/user_management/authenticate', [
                'grant_type' => 'authorization_code',
                'client_id' => config('services.workos.client_id'),
                'client_secret' => config('services.workos.api_key'),
                'code' => $request->code,
            ]);

        if (!$response->successful()) {
            return response()->json([
                'error' => 'Authentication failed',
                'details' => $response->json(),
            ], 401);
        }

        $data = $response->json();
        $workosUser = $data['user'];

        // Find or create user
        $user = User::updateOrCreate(
            ['workos_id' => $workosUser['id']],
            [
                'name' => $workosUser['first_name'] . ' ' . $workosUser['last_name'],
                'email' => $workosUser['email'],
                'avatar' => $workosUser['profile_picture_url'] ?? null,
            ]
        );

        $this->updateUserLocation($user, $request);

        // Create Sanctum token
        $token = $user->createToken('api')->plainTextToken;

        return response()->json([
            'accessToken' => $token,
            'user' => new UserResource($user->fresh()),
        ]);
    }

    public function me(Request $request)
    {
        return response()->json([
            'user' => new UserResource($request->user()),
        ]);
    }

    public function updateProfile(Request $request)
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:16',
            'bio' => 'sometimes|nullable|string|max:140',
            'avatar' => 'sometimes|nullable|string',
            'gender' => 'sometimes|in:male,female,other',
            'birthdate' => ['sometimes', 'date', 'before_or_equal:' . now()->subYears(18)->format('Y-m-d')],
        ]);

        $user = $request->user();
        $user->update($validated);

        return response()->json([
            'user' => new UserResource($user->fresh()),
        ]);
    }

    public function logout(Request $request)
    {
        // Stateless API: revoke tokens.
        // We revoke *all* tokens for the user to keep the boilerplate simple and predictable.
        // (Swap to currentAccessToken()->delete() later if you want per-device tokens.)
        $request->user()?->tokens()->delete();

        return response()->json([
            'ok' => true,
        ]);
    }
}


