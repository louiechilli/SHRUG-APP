<?php

use Illuminate\Support\Facades\Route;

// Intentionally minimal. This project is API-only and does not use Blade.
Route::get('/', fn () => response()->json([
    'message' => 'API only',
]));
