# Thiết Kế Hệ Thống API Chức Năng Trực Ban

## Base URL

> [!IMPORTANT]
> **Base URL thực tế của app (từ [AppConfig](file:///Users/samcom/flutter_projects/attendancebyface/lib/core/app_config.dart#2-95)):**
>
> - Default: `https://auth.samcom.com.vn`
> - Discovery đơn vị: `https://baseurl.samcom.com.vn/api/don_vi`

Các endpoint API trực ban sẽ được thêm prefix `/api` vào base URL:

```
https://auth.samcom.com.vn/api
```

---

## 1. API Xác Định Nhóm Người Dùng (Cốt lõi)

| Thuộc tính   | Giá trị                     |
| ------------ | --------------------------- |
| **Method**   | `GET`                       |
| **Endpoint** | `/xac-dinh-nhom-nguoi-dung` |
| **Auth**     | Bearer Token (JWT)          |

**Response:**

```json
{
  "success": true,
  "data": {
    "nhomQuyen": "TRUC_BAN",
    "moTaQuyen": "Trực ban"
  }
}
```

> [!NOTE]
>
> - `nhomQuyen`: `BINH_THUONG` | `TRUC_BAN` | `LANH_DAO_PHONG` | `LANH_DAO`
> - `LANH_DAO_PHONG`: Lãnh đạo phòng - quyền như `BINH_THUONG` + phê duyệt yêu cầu ra ngoài

---

## 2. Nhóm Chức Năng Chung (Cho tất cả User)

### 2.1 Lấy Danh Sách Trực Ban

| Thuộc tính       | Giá trị                   |
| ---------------- | ------------------------- |
| **Method**       | `GET`                     |
| **Endpoint**     | `/lay-danh-sach-truc-ban` |
| **Query Params** | `ngay=2025-01-20`         |

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "TB001",
      "hoTen": "Lê Văn B",
      "soDienThoai": "0912345678",
      "donVi": "Cơ quan Công ty",
      "caTruc": 1,
      "thoiGianBatDau": "01:00",
      "thoiGianKetThuc": "06:00"
    }
  ]
}
```

---

### 2.2 Đăng Ký Khách

| Thuộc tính   | Giá trị          |
| ------------ | ---------------- |
| **Method**   | `POST`           |
| **Endpoint** | `/dang-ky-khach` |

**Request Body:**

```json
{
  "hoTenKhach": "Nguyễn Văn A",
  "soCanCuoc": "123456789012",
  "bienSoXe": "30H-12345",
  "loaiPhuongTien": "OTO",
  "ngayDangKy": "2025-01-20"
}
```

> [!NOTE]
>
> - `loaiPhuongTien`: `OTO` | `KHAC`

**Response:**

```json
{
  "success": true,
  "message": "Đăng ký khách thành công"
}
```

---

### 2.3 Xem Lịch Sử Khách Của Mình

| Thuộc tính       | Giá trị                      |
| ---------------- | ---------------------------- |
| **Method**       | `GET`                        |
| **Endpoint**     | `/xem-lich-su-khach-ca-nhan` |
| **Query Params** | `ngay=2025-01-20`            |

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "KH202501200001",
      "hoTenKhach": "Nguyễn Văn A",
      "soCanCuoc": "123456789012",
      "bienSoXe": "30H-12345",
      "loaiPhuongTien": "OTO",
      "ngayDangKy": "2025-01-20",
      "trangThai": "DA_DANG_KY",
      "thoiGianTao": "2025-01-20T08:30:00Z"
    }
  ]
}
```

---

### 2.4 Đăng Ký Ra Ngoài

| Thuộc tính   | Giá trị             |
| ------------ | ------------------- |
| **Method**   | `POST`              |
| **Endpoint** | `/dang-ky-ra-ngoai` |

**Request Body:**

```json
{
  "thoiGianRa": "2025-01-20T09:00:00+07:00",
  "thoiGianVao": "2025-01-20T11:00:00+07:00",
  "lyDo": "Đi gặp khách hàng"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Đăng ký ra ngoài thành công"
}
```

---

### 2.5 Xem Lịch Sử Ra Ngoài Của Mình

| Thuộc tính       | Giá trị                     |
| ---------------- | --------------------------- |
| **Method**       | `GET`                       |
| **Endpoint**     | `/lich-su-ra-ngoai-ca-nhan` |
| **Query Params** | `ngay=2025-01-20`           |

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "RN202501200001",
      "thoiGianRa": "2025-01-20T09:00:00+07:00",
      "thoiGianVao": "2025-01-20T11:00:00+07:00",
      "lyDo": "Đi gặp khách hàng",
      "trangThai": "DA_DUYET",
      "nguoiDuyet": "Trần Văn C",
      "thoiGianDuyet": "2025-01-20T08:45:00+07:00"
    }
  ]
}
```

> [!NOTE]
>
> - `trangThai`: `CHO_DUYET` | `DA_DUYET` | `TU_CHOI`

---

### 2.6 Mở Cửa

| Thuộc tính   | Giá trị   |
| ------------ | --------- |
| **Method**   | `POST`    |
| **Endpoint** | `/mo-cua` |

**Request Body:**

```json
{
  "loaiPhuongTien": "OTO"
}
```

**Response - Thành công:**

```json
{
  "success": true,
  "message": "Mở cửa thành công"
}
```

**Response - Bị khóa (User thường):**

```json
{
  "success": false,
  "message": "Hệ thống đang bị khóa. Vui lòng liên hệ trực ban."
}
```

---

## 3. Nhóm Chức Năng Mở Rộng (Cho Trực ban & Lãnh đạo)

### 3.1 Xem Lịch Sử Khách Toàn Đơn Vị

| Thuộc tính       | Giá trị                 |
| ---------------- | ----------------------- |
| **Method**       | `GET`                   |
| **Endpoint**     | `/ds-khach-toan-don-vi` |
| **Query Params** | `ngay=2025-01-20`       |
| **Quyền hạn**    | `TRUC_BAN`, `LANH_DAO`  |

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "KH202501200001",
      "nguoiDangKy": {
        "id": "NV001",
        "hoTen": "Nhân viên A",
        "donVi": "Phòng Kỹ thuật"
      },
      "hoTenKhach": "Nguyễn Văn A",
      "soCanCuoc": "123456789012",
      "bienSoXe": "30H-12345",
      "loaiPhuongTien": "OTO",
      "ngayDangKy": "2025-01-20",
      "trangThai": "DA_DANG_KY",
      "thoiGianTao": "2025-01-20T08:30:00Z"
    }
  ]
}
```

---

## 4. Nhóm Chức Năng Quản Trị (Dành riêng cho Trực ban)

### 4.1 Lấy Trạng Thái Khóa Hệ Thống

| Thuộc tính    | Giá trị                     |
| ------------- | --------------------------- |
| **Method**    | `GET`                       |
| **Endpoint**  | `/he-thong/trang-thai-khoa` |
| **Quyền hạn** | `TRUC_BAN`                  |

**Response:**

```json
{
  "success": true,
  "data": {
    "trangThai": "MO"
  }
}
```

---

### 4.2 Thay Đổi Trạng Thái Khóa

| Thuộc tính    | Giá trị                              |
| ------------- | ------------------------------------ |
| **Method**    | `PUT`                                |
| **Endpoint**  | `/he-thong/thay-doi-trang-thai-khoa` |
| **Quyền hạn** | `TRUC_BAN`                           |

**Request Body:**

```json
{
  "trangThai": "KHOA"
}
```

> [!NOTE]
>
> - `trangThai`: `KHOA` | `MO`

**Response:**

```json
{
  "success": true,
  "message": "Hệ thống đã bị khóa"
}
```

**Response - Không có quyền:**

```json
{
  "success": false,
  "message": "Bạn không có quyền thực hiện chức năng này"
}
```

---

### 4.3 Danh Sách Yêu Cầu Ra Ngoài

| Thuộc tính       | Giá trị                               |
| ---------------- | ------------------------------------- |
| **Method**       | `GET`                                 |
| **Endpoint**     | `/danh-sach-yeu-cau-ra-ngoai`         |
| **Query Params** | `ngay=2025-01-20&trangThai=CHO_DUYET` |
| **Quyền hạn**    | `LANH_DAO_PHONG`                      |

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "RN202501200001",
      "nhanVien": {
        "id": "NV001",
        "hoTen": "Nguyễn Văn A",
        "donVi": "Phòng Kỹ thuật"
      },
      "thoiGianRa": "2025-01-20T09:00:00+07:00",
      "thoiGianVao": "2025-01-20T11:00:00+07:00",
      "lyDo": "Đi gặp khách hàng",
      "trangThai": "CHO_DUYET",
      "thoiGianTao": "2025-01-20T08:30:00+07:00"
    }
  ]
}
```

---

### 4.4 Phê Duyệt/Từ Chối Yêu Cầu Ra Ngoài

| Thuộc tính    | Giá trị                |
| ------------- | ---------------------- |
| **Method**    | `PUT`                  |
| **Endpoint**  | `/ra-ngoai/{id}/duyet` |
| **Quyền hạn** | `LANH_DAO_PHONG`       |

**Request Body:**

```json
{
  "hanhDong": "DUYET"
}
```

> [!NOTE]
>
> - `hanhDong`: `DUYET` | `TU_CHOI`

**Response:**

```json
{
  "success": true,
  "message": "Đã duyệt yêu cầu ra ngoài"
}
```

---

## Ma Trận Phân Quyền

| Chức năng                     |     User Thường      | Trực ban | LĐ Phòng | Lãnh đạo |
| ----------------------------- | :------------------: | :------: | :------: | :------: |
| Xem danh sách trực ban        |          ✅          |    ✅    |    ✅    |    ✅    |
| Đăng ký khách                 |          ✅          |    ✅    |    ✅    |    ✅    |
| Xem khách của mình            |          ✅          |    ✅    |    ✅    |    ✅    |
| Đăng ký ra ngoài              |          ✅          |    ✅    |    ✅    |    ✅    |
| Xem lịch sử ra ngoài của mình |          ✅          |    ✅    |    ✅    |    ✅    |
| Mở cửa                        | ⚠️ (Trừ khi bị khóa) |    ✅    |    ⚠️    |    ✅    |
| Xem khách toàn đơn vị         |          ❌          |    ✅    |    ❌    |    ✅    |
| Xem yêu cầu ra ngoài          |          ❌          |    ❌    |    ✅    |    ❌    |
| Duyệt yêu cầu ra ngoài        |          ❌          |    ❌    |    ✅    |    ❌    |
| Khóa/Mở khóa hệ thống         |          ❌          |    ✅    |    ❌    |    ❌    |

---

## Tổng Hợp Endpoints

| #   | Method | Endpoint                             | Mô tả                    |
| --- | ------ | ------------------------------------ | ------------------------ |
| 1   | GET    | `/xac-dinh-nhom-nguoi-dung`          | Lấy quyền hạn user       |
| 2   | GET    | `/lay-danh-sach-truc-ban`            | Danh sách trực ban       |
| 3   | POST   | `/dang-ky-khach`                     | Đăng ký khách            |
| 4   | GET    | `/xem-lich-su-khach-ca-nhan`         | Lịch sử khách cá nhân    |
| 5   | GET    | `/ds-khach-toan-don-vi`              | Lịch sử khách đơn vị     |
| 6   | POST   | `/dang-ky-ra-ngoai`                  | Đăng ký ra ngoài         |
| 7   | GET    | `/lich-su-ra-ngoai-ca-nhan`          | Lịch sử ra ngoài cá nhân |
| 8   | GET    | `/danh-sach-yeu-cau-ra-ngoai`        | DS yêu cầu ra ngoài      |
| 9   | PUT    | `/ra-ngoai/{id}/duyet`               | Duyệt yêu cầu ra ngoài   |
| 10  | POST   | `/mo-cua`                            | Mở cửa                   |
| 11  | GET    | `/he-thong/trang-thai-khoa`          | Lấy trạng thái khóa      |
| 12  | PUT    | `/he-thong/thay-doi-trang-thai-khoa` | Thay đổi trạng thái khóa |

---

## Response Format Chuẩn

**Success:**

```json
{
  "success": true,
  "message": "Thông báo thành công"
}
```

**Success với data:**

```json
{
  "success": true,
  "data": { ... }
}
```

**Error:**

```json
{
  "success": false,
  "message": "Mô tả lỗi chi tiết"
}
```
