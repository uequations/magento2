<?php
/**
 * Copyright 2022 Adobe
 * All Rights Reserved.
 */

declare(strict_types=1);

namespace Magento\AdobeImsApi\Api;

/**
 * Declare functionality for getting user access token
 * @api
 */
interface GetAccessTokenInterface
{
    /**
     * Get adobe access token for specified or current admin user
     *
     * @param int $adminUserId
     * @return string|null
     */
    public function execute(?int $adminUserId = null): ?string;
}
