<?php

namespace App\Services;

use BoogieFromZk\AgoraToken\RtcTokenBuilder2;

class AgoraTokenService
{
    private string $appId;
    private string $appCertificate;

    public function __construct()
    {
        $this->appId = config('services.agora.app_id');
        $this->appCertificate = config('services.agora.app_certificate');
    }

    public function generateRtcToken(string $channelName, int $uid, int $expiresInSeconds = 3600): string
    {
        return RtcTokenBuilder2::buildTokenWithUid(
            $this->appId,
            $this->appCertificate,
            $channelName,
            $uid,
            RtcTokenBuilder2::ROLE_PUBLISHER,
            $expiresInSeconds
        );
    }
}
