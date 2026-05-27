CREATE TABLE IF NOT EXISTS warranty_request_image_urls (
    warranty_request_id BIGINT NOT NULL,
    image_url           TEXT   NOT NULL,
    CONSTRAINT fk_wriu_warranty FOREIGN KEY (warranty_request_id)
        REFERENCES warranty_requests (id) ON DELETE CASCADE
);
