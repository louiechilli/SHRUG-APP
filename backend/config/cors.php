<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | This app is a decoupled API. Configure allowed origins via env:
    | - FRONTEND_URL=http://localhost:5173
    | - CORS_ALLOWED_ORIGINS=http://localhost:5173,https://your-frontend.app
    |
    */

    'paths' => ['api/*'],

    'allowed_methods' => ['*'],

    'allowed_origins' => [
        'http://localhost:5173',
        'https://442ff7d37ad5.ngrok-free.app',
        'https://getshrug.app',
        'http://getshrug.app', // Fallback for HTTP
    ],

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    // For stateless Bearer token auth, credentials are not required.
    'supports_credentials' => false,
];


