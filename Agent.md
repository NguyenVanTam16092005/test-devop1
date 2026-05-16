Tài liệu Mô tả Giao diện: Hệ thống Quản lý Học sinh - Sinh viên (SIS)
Tài liệu này mô tả chi tiết về cấu trúc, thiết kế và các thành phần giao diện (UI) của module "Quản lý Học sinh - Sinh viên", phục vụ cho việc tích hợp vào Frontend (ReactJS) của dự án MERN Stack SIS.
1. Tổng quan Thiết kế
Phong cách thiết kế: Hiện đại, tối giản (Minimalism), Clean UI.
Màu sắc chủ đạo: - Primary: Indigo (Xanh tím - indigo-600, indigo-800 cho Sidebar).
Background: Xám nhạt (gray-50, gray-100) giúp nổi bật các thẻ nội dung (Card).
Trạng thái: Xanh lá (Thành công), Đỏ (Cảnh báo/Lỗi), Xanh dương/Hồng (Phân loại giới tính).
Typography: Font chữ Inter (Google Fonts) mang lại cảm giác thân thiện, dễ đọc cho các ứng dụng bảng biểu.
Tính đáp ứng (Responsive): Hỗ trợ đầy đủ hiển thị trên Desktop, Tablet và Mobile.
2. Công nghệ & Thư viện UI
CSS Framework: Tailwind CSS.
Icons: FontAwesome 6 (Sử dụng các class fas fa-*).
Google Fonts: Inter (wght@300;400;500;600;700).
3. Cấu trúc Layout Tổng thể (Layout Structure)
Giao diện được chia thành một khung layout cố định toàn màn hình (h-screen overflow-hidden) bao gồm 2 phần chính:
Sidebar (Bên trái): Chứa logo, menu điều hướng và thông tin User.
Trên Desktop: Cố định bên trái (w-64).
Trên Mobile: Ẩn đi (-translate-x-full) và có thể mở ra thông qua nút Hamburger menu. Đi kèm với một lớp nền tối (overlay).
Main Content (Bên phải): Phần hiển thị nội dung chính, chiếm phần diện tích còn lại (flex-1).
Bao gồm Header tĩnh ở trên và vùng nội dung cuộn (overflow-auto) ở dưới.
4. Chi tiết các Thành phần (UI Components)
4.1. Header Component
Tiêu đề trang: Tên module đang hoạt động.
Thanh tìm kiếm (Search Bar): Nằm góc phải (trên Desktop) hoặc đẩy xuống dưới (trên Mobile), cho phép tìm kiếm realtime theo Tên hoặc MSSV.
Nút "Thêm Mới" (Call to Action): Nổi bật với màu Indigo, có icon dấu cộng +.
4.2. Dashboard Stats (Thẻ thống kê)
Nằm ngay trên bảng dữ liệu, bao gồm 3 thẻ (Card) tổng hợp số liệu realtime:
Tổng số HSSV: Nền icon xanh dương.
Nam: Nền icon xanh lá.
Nữ: Nền icon hồng.
Hành vi: Có hiệu ứng số nhảy (Count up animation) khi dữ liệu thay đổi.
4.3. Data Table (Bảng dữ liệu)
Cấu trúc: Bảng có nền trắng, viền xám nhạt (rounded-xl, shadow-sm). Hỗ trợ cuộn ngang trên màn hình nhỏ.
Cột dữ liệu: MSSV, Họ và Tên (kèm Avatar chữ cái đầu), Ngày sinh, Giới tính (dạng Badge màu), Lớp, Ngành học, Thao tác.
Trạng thái trống (Empty State): Khi không có dữ liệu, bảng sẽ ẩn đi và hiển thị một khối đồ họa trống (Icon thư mục mở) kèm thông báo "Chưa có dữ liệu".
Hành động (Actions): Các nút Sửa/Xóa. Trên Desktop, chúng sẽ ẩn đi và chỉ hiện ra khi hover (group-hover:opacity-100) vào hàng đó để giao diện đỡ rối.
4.4. Modals & Forms
Form Thêm/Sửa HSSV:
Hiển thị dạng Popup (Modal) ở giữa màn hình với nền tối mờ (backdrop-blur-sm).
Gồm các trường:
Input Text: MSSV, Họ và Tên, Lớp.
Input Date: Ngày sinh.
Radio Button: Giới tính (Nam/Nữ).
Select Dropdown: Ngành học.
Các trường bắt buộc có dấu * màu đỏ.
Hộp thoại Xác nhận (Confirm Dialog):
Hiển thị khi người dùng bấm nút Xóa.
Giao diện cảnh báo (Icon chấm than đỏ) thay thế cho hàm window.confirm() mặc định của trình duyệt để đảm bảo tính đồng bộ UI.
4.5. Toast Notifications (Hệ thống thông báo)
Vị trí: Trượt ra từ góc trên cùng bên phải màn hình.
Các loại: Thành công (Xanh lá), Lỗi (Đỏ).
Hành vi: Tự động biến mất sau 3 giây, có hiệu ứng trượt mượt mà.
5. Gợi ý cấu trúc React Components cho dự án MERN
Khi đưa giao diện này vào React Frontend, bạn nên chia nhỏ (break down) UI thành các file Component sau:
src/
 ┣ components/
 ┃ ┣ layout/
 ┃ ┃ ┣ Sidebar.jsx          // Menu bên trái
 ┃ ┃ ┣ Header.jsx           // Thanh điều hướng trên, chứa Search & nút Thêm
 ┃ ┃ ┗ DashboardLayout.jsx  // Wrapper chứa Sidebar, Header và the {children}
 ┃ ┣ common/
 ┃ ┃ ┣ StatsCard.jsx        // Tái sử dụng cho 3 ô thống kê
 ┃ ┃ ┣ Badge.jsx            // Hiển thị Giới tính/Trạng thái
 ┃ ┃ ┣ Modal.jsx            // Wrapper cho Form Modal và Confirm Modal
 ┃ ┃ ┗ ToastNotification.jsx// Context/Component quản lý thông báo
 ┃ ┗ student/
 ┃   ┣ StudentTable.jsx     // Bảng danh sách HSSV
 ┃   ┣ StudentRow.jsx       // (Tùy chọn) Component cho từng dòng
 ┃   ┗ StudentForm.jsx      // Form Thêm/Sửa HSSV
 ┣ pages/
 ┃ ┗ StudentManagement.jsx  // Trang chính, gọi API và truyền state xuống các components


6. Ghi chú tích hợp Backend
Khi chuyển sang React, các state đang được dùng bằng biến mảng (let students = []) sẽ cần chuyển thành useState hoặc Redux/Zustand.
Tích hợp Axios/Fetch vào StudentManagement.jsx để gọi các API từ NodeJS Backend:
GET /api/students -> Đổ vào StudentTable.
POST /api/students -> Nối vào StudentForm (khi tạo mới).
PUT /api/students/:id -> Nối vào StudentForm (khi sửa).
DELETE /api/students/:id -> Nối vào nút Xóa trong Table.
