# Tổng hợp lỗi deploy Render (BE-3)

## Mục đích
File này ghi lại các lỗi đã gặp khi deploy backend BE-3 lên Render, theo kiểu dễ kiểm tra lại từng bước.

## 1) Chọn sai runtime ban đầu (Node thay vì Java/Docker)
- **Dấu hiệu**: màn hình tạo service hiện `Language: Node`, `Build Command: yarn`, `Start Command: yarn start`.
- **Nguyên nhân**: project là Spring Boot + Maven (Java), không phải Node app.
- **Cách đúng**:
  - Dùng **Docker runtime** trên Render.
  - Không dùng `yarn` cho service này.

## 2) Thiếu Dockerfile ở vị trí Render đang đọc
- **Dấu hiệu**: deploy fail sớm khi build image.
- **Nguyên nhân**: Render chạy Docker runtime nhưng không tìm được Dockerfile hợp lệ theo cấu hình đường dẫn.
- **Đã xử lý**: đã thêm Dockerfile vào repo.

## 3) Sai Root Directory / Docker context => path bị nhân đôi
- **Log lỗi thực tế**:
  - `error: invalid local: resolve . lstat /opt/render/project/src/ash-project-be/ash-project-be: no such file or directory`
- **Nguyên nhân**: cấu hình đường dẫn trên Render bị lệch, dẫn tới Render tìm thư mục lặp `ash-project-be/ash-project-be`.
- **Cấu hình chuẩn nên dùng**:
  - `Root Directory`: `ash-project-be`
  - `Dockerfile Path`: `Dockerfile`
  - `Docker Build Context Directory`: `.`

## 4) Nhập ENV vars sai format (dán 1 dòng có dấu `;`)
- **Dấu hiệu**: app có thể lỗi lúc start vì không đọc đúng biến môi trường.
- **Nguyên nhân**: Render yêu cầu mỗi biến là 1 dòng key-value riêng.
- **Cách đúng**: tạo riêng từng biến:
  - `DB_URL`
  - `DB_USERNAME`
  - `DB_PASSWORD`
  - `JWT_SIGNER_KEY`

## 5) Mở domain gốc bị 404 (không phải lỗi deploy)
- **Dấu hiệu**: truy cập `https://<service>.onrender.com/` thấy `HTTP Status 404`.
- **Nguyên nhân**: backend không có endpoint `/`, và đang đặt context path:
  - `server.servlet.context-path=/api/v1`
- **URL test đúng**:
  - `https://<service>.onrender.com/api/v1/user`
  - `https://<service>.onrender.com/api/v1/swagger-ui/index.html`

## Checklist nhanh trước khi bấm deploy
1. Đúng runtime: **Docker**.
2. Đúng đường dẫn:
   - Root Directory = `ash-project-be`
   - Dockerfile Path = `Dockerfile`
   - Docker Build Context Directory = `.`
3. Đủ 4 ENV vars (mỗi biến 1 dòng).
4. Deploy lại bằng **Clear build cache & deploy latest commit**.
5. Test bằng URL có `/api/v1/...`, không test root `/`.

## Ghi chú bảo mật
Bạn đã từng gửi `DB_PASSWORD` và `JWT_SIGNER_KEY` công khai trong chat. Nên **rotate** lại 2 secret này sau khi hệ thống chạy ổn định.
