package util;

/**
 * AuditDescription - Chuẩn hoá định dạng mô tả (description) cho audit log.
 *
 * QUY ƯỚC CHUNG (áp dụng cho toàn bộ dòng log):
 *
 *   {Đối tượng} | {Hành động} | {Trường}: {Giá trị cũ} -> {Giá trị mới} | {Ghi chú}
 *
 * Quy tắc:
 *  - Dùng " | " (dấu phân cách trường) giữa các phần.
 *  - Dùng " -> " (mũi tên) để biểu diễn "giá trị cũ -> giá trị mới".
 *  - Các trường "giá trị cũ -> giá trị mới" có thể lặp lại nhiều lần.
 *  - Trường đầu tiên (đối tượng) và trường cuối (ghi chú) luôn có.
 *  - TUYỆT ĐỐI KHÔNG chứa ký tự " | " trong nội dung tự do
 *    (nếu cần thì thay bằng dấu phẩy).
 *
 * Ví dụ:
 *   Tài khoản nv001 | Cập nhật | Email: a@b.com -> c@d.com | Vai trò: Employee -> Store Manager | Bởi admin_user
 *   Phòng ban Kế toán | Xóa | id=3 | Bởi admin_user
 */
public final class AuditDescription {

    /** Dấu phân cách trường. */
    public static final String SEP = " | ";

    /** Dấu mũi tên "giá trị cũ -> giá trị mới". */
    public static final String ARROW = " -> ";

    private AuditDescription() {
        // Lớp tiện ích - không cho phép khởi tạo
    }

    // =========================================================
    //  CÁC HẰNG SỐ MÔ TẢ HÀNH ĐỘNG
    // =========================================================

    // ---- Đăng nhập / đăng xuất ----
    public static final String ACT_LOGIN       = "Đăng nhập";
    public static final String ACT_LOGOUT      = "Đăng xuất";
    public static final String ACT_LOGIN_FAIL  = "Đăng nhập thất bại";

    // ---- Tài khoản ----
    public static final String ACT_CREATE_USER = "Tạo";
    public static final String ACT_UPDATE_USER = "Cập nhật";
    public static final String ACT_LOCK        = "Khóa";
    public static final String ACT_UNLOCK      = "Mở khóa";
    public static final String ACT_RESET_PW    = "Reset mật khẩu";

    // ---- Master data ----
    public static final String ACT_CREATE      = "Tạo";
    public static final String ACT_UPDATE      = "Cập nhật";
    public static final String ACT_DELETE      = "Xóa";

    // =========================================================
    //  HÀM DỰNG DESCRIPTION
    // =========================================================

    /**
     * Dựng description cho hành động đăng nhập / đăng xuất / đăng nhập thất bại.
     *
     * @param username  tên đăng nhập của tài khoản
     * @param actorName tên người thực hiện (có thể null)
     * @param success   true = thành công, false = thất bại
     */
    public static String auth(String username, String actorName, boolean success) {
        StringBuilder sb = new StringBuilder();
        sb.append("Tài khoản ").append(safe(username)).append(SEP);
        sb.append(success ? ACT_LOGIN : ACT_LOGIN_FAIL).append(SEP);
        sb.append(success ? "Thành công" : "Thất bại - sai tên đăng nhập hoặc mật khẩu");
        if (!success && actorName != null && !actorName.trim().isEmpty()) {
            sb.append(SEP).append("Tài khoản tồn tại: ").append(safe(actorName));
        }
        return sb.toString();
    }

    /**
     * Dựng description cho hành động đăng xuất.
     */
    public static String logout(String username, String actorName) {
        StringBuilder sb = new StringBuilder();
        sb.append("Tài khoản ").append(safe(username)).append(SEP);
        sb.append(ACT_LOGOUT).append(SEP).append("Thành công");
        if (actorName != null && !actorName.trim().isEmpty()) {
            sb.append(SEP).append("Bởi ").append(safe(actorName));
        }
        return sb.toString();
    }

    /**
     * Dựng description cho hành động tạo tài khoản.
     *
     * @param username    mã nhân viên / username
     * @param fullName    họ tên (có thể null)
     * @param roleName    tên vai trò
     * @param branchName  tên chi nhánh (có thể null)
     * @param actorName   người thực hiện
     */
    public static String createUser(String username, String fullName, String roleName,
                                    String branchName, String actorName) {
        StringBuilder sb = new StringBuilder();
        sb.append("Tài khoản ").append(safe(username));
        if (fullName != null && !fullName.trim().isEmpty()) {
            sb.append(" (").append(safe(fullName)).append(")");
        }
        sb.append(SEP).append(ACT_CREATE_USER).append(SEP);
        if (roleName != null && !roleName.trim().isEmpty()) {
            sb.append("Vai trò: ").append(safe(roleName)).append(SEP);
        }
        if (branchName != null && !branchName.trim().isEmpty()) {
            sb.append("Chi nhánh: ").append(safe(branchName)).append(SEP);
        }
        sb.append("Mật khẩu mặc định: 123456");
        appendActor(sb, actorName);
        return sb.toString();
    }

    /**
     * Dựng description cho hành động cập nhật tài khoản.
     *
     * @param username  mã nhân viên / username
     * @param changes   danh sách thay đổi dạng "Trường: cũ -> mới" (đã format sẵn)
     * @param actorName người thực hiện
     */
    public static String updateUser(String username, String changes, String actorName) {
        StringBuilder sb = new StringBuilder();
        sb.append("Tài khoản ").append(safe(username)).append(SEP);
        sb.append(ACT_UPDATE_USER).append(SEP);
        if (changes != null && !changes.trim().isEmpty()) {
            sb.append(safe(changes));
        } else {
            sb.append("Không có thay đổi nào");
        }
        appendActor(sb, actorName);
        return sb.toString();
    }

    /**
     * Dựng 1 phần thay đổi theo chuẩn "Trường: giá trị cũ -> giá trị mới".
     */
    public static String change(String field, Object oldValue, Object newValue) {
        return safe(field) + ": " + safe(oldValue) + ARROW + safe(newValue);
    }

    /**
     * Dựng description cho hành động khóa / mở khóa tài khoản.
     *
     * @param username   tài khoản bị tác động
     * @param actionName "Khóa" hoặc "Mở khóa"
     * @param reason     lý do (chỉ dùng cho khóa, có thể null)
     * @param actorName  người thực hiện
     */
    public static String lock(String username, String actionName, String reason, String actorName) {
        StringBuilder sb = new StringBuilder();
        sb.append("Tài khoản ").append(safe(username)).append(SEP);
        sb.append(actionName).append(SEP);
        if (reason != null && !reason.trim().isEmpty()) {
            sb.append("Lý do: ").append(safe(reason)).append(SEP);
        }
        sb.append("Trạng thái: ")
          .append("Khóa".equals(actionName) ? "EMERGENCY_LOCKED" : "ACTIVE");
        appendActor(sb, actorName);
        return sb.toString();
    }

    /**
     * Dựng description cho hành động reset mật khẩu.
     */
    public static String resetPassword(String username, String actorName) {
        StringBuilder sb = new StringBuilder();
        sb.append("Tài khoản ").append(safe(username)).append(SEP);
        sb.append(ACT_RESET_PW).append(SEP);
        sb.append("Mật khẩu: (cũ) -> 123456");
        appendActor(sb, actorName);
        return sb.toString();
    }

    /**
     * Dựng description cho thao tác CRUD trên Master Data
     * (phòng ban / vị trí / vai trò).
     *
     * @param entityLabel nhãn loại đối tượng: "Phòng ban" / "Vị trí" / "Vai trò"
     * @param entityName  tên đối tượng
     * @param entityId    id đối tượng
     * @param actionName  "Tạo" / "Cập nhật" / "Xóa"
     * @param extra       thông tin bổ sung (có thể null), VD: tên mới khi đổi tên
     * @param actorName   người thực hiện
     */
    public static String masterData(String entityLabel, String entityName, int entityId,
                                    String actionName, String extra, String actorName) {
        StringBuilder sb = new StringBuilder();
        sb.append(entityLabel).append(" ").append(safe(entityName))
          .append(" (id=").append(entityId).append(")").append(SEP);
        sb.append(actionName).append(SEP);
        if (extra != null && !extra.trim().isEmpty()) {
            sb.append(safe(extra)).append(SEP);
        }
        sb.append("Bởi ").append(actorName == null ? "system" : safe(actorName));
        return sb.toString();
    }

    // =========================================================
    //  HÀM PHỤ
    // =========================================================

    /**
     * Thêm phần "Bởi {actor}" vào cuối description nếu có.
     */
    private static void appendActor(StringBuilder sb, String actorName) {
        if (actorName != null && !actorName.trim().isEmpty()) {
            sb.append(SEP).append("Bởi ").append(safe(actorName));
        }
    }

    /**
     * Làm sạch chuỗi: thay ký tự phân cách trường và mũi tên để không phá vỡ format.
     */
    private static String safe(String value) {
        if (value == null) return "";
        return value.replace("|", "/").replace("\r\n", " ").replace("\n", " ").replace("\r", " ").trim();
    }

    private static String safe(Object value) {
        return safe(value == null ? "" : String.valueOf(value));
    }
}
