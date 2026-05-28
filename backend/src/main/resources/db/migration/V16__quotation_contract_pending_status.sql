-- V16: Add quotation states after staff sends an approved quotation to customer.
-- CONTRACT_PENDING = customer agreed, waiting for contract signing.
-- CUSTOMER_REJECTED = customer rejected the quotation.

ALTER TABLE quotations
    MODIFY COLUMN status ENUM(
        'PENDING', 'QUOTED', 'ACCEPTED', 'REJECTED', 'EXPIRED',
        'DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'SENT',
        'CONTRACT_PENDING', 'CUSTOMER_REJECTED'
    ) NOT NULL DEFAULT 'PENDING';
