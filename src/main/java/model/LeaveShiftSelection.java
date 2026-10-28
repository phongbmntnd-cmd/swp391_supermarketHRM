package model;

import java.time.LocalDate;

/**
 * Một ca mà nhân viên chọn để xin nghỉ (dùng cho part-time).
 *
 * Form gửi lên tham số "selectedShifts" theo định dạng:
 *     yyyy-MM-dd_shiftId
 * Ví dụ: 2026-11-03_3  => nghỉ ca id=3 (Ca Tối) ngày 03/11/2026
 */
public class LeaveShiftSelection {

    private final LocalDate workDate;
    private final int shiftId;

    public LeaveShiftSelection(LocalDate workDate, int shiftId) {
        this.workDate = workDate;
        this.shiftId = shiftId;
    }

    public LocalDate getWorkDate() {
        return workDate;
    }

    public int getShiftId() {
        return shiftId;
    }

    /**
     * Phân tích chuỗi "yyyy-MM-dd_shiftId".
     * Trả về null nếu chuỗi không hợp lệ.
     */
    public static LeaveShiftSelection parse(String raw) {
        if (raw == null) {
            return null;
        }
        String value = raw.trim();
        if (value.isEmpty()) {
            return null;
        }

        int sep = value.lastIndexOf('_');
        if (sep <= 0 || sep == value.length() - 1) {
            return null;
        }

        String datePart = value.substring(0, sep);
        String shiftPart = value.substring(sep + 1);

        LocalDate date;
        int shiftId;
        try {
            date = LocalDate.parse(datePart);
            shiftId = Integer.parseInt(shiftPart);
        } catch (Exception e) {
            return null;
        }

        if (shiftId <= 0) {
            return null;
        }

        return new LeaveShiftSelection(date, shiftId);
    }

    @Override
    public String toString() {
        return workDate + "_" + shiftId;
    }
}
