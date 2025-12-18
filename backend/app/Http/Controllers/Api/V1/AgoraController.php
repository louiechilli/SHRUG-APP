<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\AgoraTokenService;
use Illuminate\Http\Request;

class AgoraController extends Controller
{
    public function token(Request $request, AgoraTokenService $agoraService)
    {
        $validated = $request->validate([
            'channel_name' => 'required|string|max:64',
        ]);

        $uid = $request->user()->id;
        $token = $agoraService->generateRtcToken($validated['channel_name'], $uid);

        return response()->json([
            'token' => $token,
            'uid' => $uid,
            'channel' => $validated['channel_name'],
        ]);
    }
}

