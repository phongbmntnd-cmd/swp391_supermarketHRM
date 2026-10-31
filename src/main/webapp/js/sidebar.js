/* ============================================================
   SIDEBAR DÙNG CHUNG - Employee / Store Manager
   - Mở/đóng submenu "Đơn từ & Khiếu nại"
   - Tự đánh dấu active theo URL hiện tại
   - Tự mở submenu chứa trang hiện tại
   ============================================================ */
(function () {
    'use strict';

    /**
     * Lấy đường dẫn hiện tại (không kèm context path), ví dụ:
     * /employee/leave-request
     */
    function currentPath() {
        var ctx = (window.location.pathname.match(/^.*?\/supermarket(?=\/|$)/) || [''])[0];
        var path = window.location.pathname;
        if (ctx && path.indexOf(ctx) === 0) {
            path = path.substring(ctx.length);
        }
        // Bỏ query string / hash
        return path.replace(/[?#].*$/, '');
    }

    /**
     * Đánh dấu menu item đang active dựa trên href.
     * Trang con (vd /employee/leave-request) sẽ làm active item cha tương ứng.
     */
    function markActive() {
        var path = currentPath();
        var links = document.querySelectorAll('.sidebar-menu a[href]');

        links.forEach(function (a) {
            var href = a.getAttribute('href');
            if (!href || href === '#' || href.indexOf('javascript:') === 0) {
                return;
            }

            // Chuyển href thành path tương đốu
            var hrefPath = href;
            var ctx = (window.location.pathname.match(/^.*?\/supermarket(?=\/|$)/) || [''])[0];
            if (ctx && hrefPath.indexOf(ctx) === 0) {
                hrefPath = hrefPath.substring(ctx.length);
            }
            hrefPath = hrefPath.replace(/[?#].*$/, '');

            if (!hrefPath || hrefPath === '/') {
                return;
            }

            var li = a.parentElement;
            var isMatch = (path === hrefPath)
                || (path.indexOf(hrefPath + '/') === 0);

            if (isMatch) {
                li.classList.add('active');
                a.classList.add('current');
            } else {
                li.classList.remove('active');
                a.classList.remove('current');
            }
        });
    }

    /**
     * Mở submenu chứa item đang active (để trang con hiện ra trong menu).
     * Đồng thời đánh dấu item cha (vd "Đơn từ & Khiếu nại") là active.
     */
    function openActiveSubmenu() {
        var current = document.querySelector('.sidebar-menu .submenu li.active');
        if (!current) {
            return;
        }

        var submenu = current.closest('.submenu');
        if (!submenu) {
            return;
        }

        submenu.classList.add('show');

        var parentLi = submenu.closest('.sidebar-menu > li');
        if (parentLi) {
            parentLi.classList.add('open');

            var btn = parentLi.querySelector('.submenu-toggle');
            if (btn) {
                btn.setAttribute('aria-expanded', 'true');
            }
        }
    }

    /**
     * Gắn sự kiện click cho nút bật/tắt submenu.
     */
    function bindToggles() {
        document.querySelectorAll('.sidebar-menu .submenu-toggle').forEach(function (btn) {
            btn.addEventListener('click', function (e) {
                e.preventDefault();
                e.stopPropagation();

                var li = btn.closest('.sidebar-menu > li');
                var submenu = li ? li.querySelector('.submenu') : null;
                if (!submenu) {
                    return;
                }

                var willOpen = !submenu.classList.contains('show');
                submenu.classList.toggle('show', willOpen);
                li.classList.toggle('open', willOpen);
                btn.setAttribute('aria-expanded', willOpen ? 'true' : 'false');
            });
        });
    }

    /**
     * Thu gọn sidebar trên mobile (nút toggle trên top-navbar).
     */
    function bindMobileToggle() {
        var toggle = document.querySelector('[data-sidebar-toggle]');
        var sidebar = document.querySelector('.sidebar');
        if (!toggle || !sidebar) {
            return;
        }
        toggle.addEventListener('click', function () {
            sidebar.classList.toggle('open');
        });
    }

    document.addEventListener('DOMContentLoaded', function () {
        markActive();
        openActiveSubmenu();
        bindToggles();
        bindMobileToggle();
    });
})();
