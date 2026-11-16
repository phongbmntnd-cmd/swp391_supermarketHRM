-- ============================================================
-- Migration: them cot notice_hours vao bang leave_types
-- Thoi gian (gio) phai bao truoc khi gui don nghi phe
-- 0  = gui trong ngay duoc (khong gioi han)
-- 48 = nghi phep nam (bao truoc 2 ngay)
-- 24 = nghi khong luong (bao truoc 1 ngay)
-- 4  = nghi om (bao truoc toi thieu 4 gio)
-- 0  = nghi tang (bao ngay)
-- ============================================================

ALTER TABLE leave_types
    ADD COLUMN notice_hours INT NOT NULL DEFAULT 48
    AFTER paid_leave;

-- Gan gia tri cho tung loai nghi
UPDATE leave_types SET notice_hours = 48 WHERE code = 'ANNUAL';
UPDATE leave_types SET notice_hours = 24 WHERE code = 'UNPAID';
UPDATE leave_types SET notice_hours = 4  WHERE code = 'SICK';
UPDATE leave_types SET notice_hours = 0  WHERE code = 'FUNERAL';

SELECT id, code, name, default_days, paid_leave, notice_hours
FROM leave_types
ORDER BY id;
