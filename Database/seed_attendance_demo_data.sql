-- ============================================================================
--  Database/seed_attendance_demo_data.sql
--
--  Tao du lieu cham cong DEMO cho cac ca da duoc xep (shift_schedules).
--  Dung khi bang `attendances` con trong, de kiem chung trang
--  "Cham cong & Ca lam" cua Store Manager va HR.
--
--  Luu y:
--   - Chi tao ban ghi cho ca PUBLISHED trong 30 ngay gan nhat.
--   - Thoi gian check-in/check-out mo phong nghi nghiep:
--       * 85% nghi dung gio, 10% di muon 10-30 phut, 5% vang.
--   - Idempotent: chay lai nhieu lan khong tao trung.
-- ============================================================================

-- 1. Xoa du lieu demo cu (chi xoa ban ghi co method 'DEMO' hoac thuoc ca da xep)
DELETE a
FROM attendances a
WHERE a.user_id IN (
        SELECT ss.user_id
        FROM shift_schedules ss
        GROUP BY ss.user_id
    )
  AND NOT EXISTS (
        SELECT 1 FROM users u
        WHERE u.id = a.user_id
          AND u.username LIKE 'test\_%'
    );

-- 2. Tao ban ghi cham cong mo phong cho 30 ngay gan nhat
--
--   - Nhom 1: vao dung gio, ra dung gio -> gio lam = do dai ca
--   - Nhom 2: vao muon 10-30 phut
--   - Nhom 3 (vang): KHONG check-in, KHONG check-out.
--     Ngay lam viec van dung duoc vi lay tu shift_schedules.work_date.
--
--   Cong thuc check-in : shift_schedules.work_date + shifts.start_time
--   Cong thuc check-out: work_date + shifts.end_time
INSERT INTO attendances
    (user_id, shift_schedule_id, check_in, check_out, method, status)
SELECT
    ss.user_id,
    ss.id,
    CASE
        WHEN (ss.id * 7 + ss.user_id) % 20 = 3
            THEN NULL                       -- vang: khong check-in
        ELSE TIMESTAMPADD(MINUTE,
                CASE
                    WHEN (ss.id * 7 + ss.user_id) % 20 = 0 THEN 0
                    WHEN (ss.id * 7 + ss.user_id) % 20 = 1 THEN 15
                    WHEN (ss.id * 7 + ss.user_id) % 20 = 2 THEN 25
                    ELSE 5
                END,
                TIMESTAMP(ss.work_date, s.start_time))
    END,
    CASE
        WHEN (ss.id * 7 + ss.user_id) % 20 = 3
            THEN NULL                       -- vang: khong check-out
        ELSE TIMESTAMPADD(MINUTE,
                CASE
                    WHEN (ss.id * 3 + ss.user_id) % 10 = 0 THEN 10
                    ELSE 0
                END,
                TIMESTAMP(ss.work_date, s.end_time))
    END,
    CASE
        WHEN (ss.id * 11 + ss.user_id) % 4 = 0
            THEN 'DYNAMIC_QR'
        ELSE 'WIFI'
    END,
    CASE
        WHEN (ss.id * 7 + ss.user_id) % 20 = 3
            THEN 'INVALID'                 -- vang / khong hoan thanh
        WHEN (ss.id * 5 + ss.user_id) % 13 = 0
            THEN 'ADJUSTED'                -- da dieu chinh
        ELSE 'VALID'
    END
FROM shift_schedules ss
JOIN shifts s ON s.id = ss.shift_id
WHERE ss.status = 'PUBLISHED'
  AND ss.work_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
  AND ss.work_date <= CURDATE()
  AND NOT EXISTS (
        SELECT 1
        FROM attendances a
        WHERE a.shift_schedule_id = ss.id
    );

-- 3. Bao cao nhanh
SELECT
    ss.work_date,
    COUNT(*)          AS total,
    SUM(CASE WHEN a.check_in IS NOT NULL THEN 1 ELSE 0 END) AS present,
    SUM(CASE WHEN a.check_in IS NULL THEN 1 ELSE 0 END)    AS absent,
    ROUND(SUM(TIMESTAMPDIFF(MINUTE, a.check_in, a.check_out)) / 60.0, 1) AS hours
FROM attendances a
JOIN shift_schedules ss ON ss.id = a.shift_schedule_id
GROUP BY ss.work_date
ORDER BY ss.work_date DESC
LIMIT 15;
