<?php

namespace Tests\Feature\Api\V1;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StatusTest extends TestCase
{
    use RefreshDatabase;

    public function test_status_returns_ok(): void
    {
        $this->getJson('/api/v1/status')
            ->assertOk()
            ->assertJson([
                'status' => 'ok',
                'version' => 'v1',
            ]);
    }
}


