# 🚀 Quản Lý Học Sinh - Setup Jenkins CI/CD Pipeline

> **Pipeline Hoàn Chỉnh: Build → Test → Deploy**

[![Phiên Bản](https://img.shields.io/badge/version-1.0.0-blue.svg?cacheSeconds=2592000)](https://github.com/NguyenVanTam16092005/test-devop1)
[![Trạng Thái](https://img.shields.io/badge/status-Ready-green.svg)](https://github.com/NguyenVanTam16092005/test-devop1)
[![Giấy Phép](https://img.shields.io/badge/license-ISC-green.svg)](LICENSE)

## 📖 Liên Kết Nhanh

| Tài Liệu | Mục Đích | Thời Gian Đọc |
|----------|---------|-----------|
| **[SETUP_SUMMARY.md](./SETUP_SUMMARY.md)** | 🎯 Tổng Quan Chi Tiết | 5 phút |
| **[SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md)** | ✅ Danh Sách Kiểm Tra | 15 phút |
| **[JENKINS_SETUP.md](./JENKINS_SETUP.md)** | 🔧 Hướng Dẫn Chi Tiết Jenkins | 30 phút |
| **[CI-CD_COMPLETE_GUIDE.md](./CI-CD_COMPLETE_GUIDE.md)** | 📚 Hướng Dẫn Tham Khảo Đầy Đủ | 1 giờ |

## 🎯 Bắt Đầu Từ Đây

### Cài Đặt Lần Đầu (5 phút)
```bash
# 1. Copy file cấu hình
cp .env.example .env
cp Backend/.env.example Backend/.env
cp Frontend/.env.example Frontend/.env

# 2. Test với Docker locally
chmod +x quick-start.sh
./quick-start.sh

# 3. Truy cập ứng dụng
# Frontend: http://localhost
# Backend:  http://localhost:8081
```

### Sau Đó Theo Dõi Danh Sách Kiểm Tra
👉 **Đọc [SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md)** - Nó hướng dẫn bạn từng bước

## 📦 Những Gì Được Bao Gồm

### ✨ Tính Năng
- ✅ **Build Tự Động**: Tạo container Docker cho Backend (Node.js) và Frontend (React)
- ✅ **Test Tự Động**: Unit test + Phân tích chất lượng code SonarQube
- ✅ **Deploy Tự Động**: Đẩy lên Docker Hub + Triển khai tới các server
- ✅ **Phê Duyệt Manual**: Triển khai production yêu cầu phê duyệt
- ✅ **Kiểm Tra Sức Khỏe**: Tự động theo dõi sức khỏe container
- ✅ **Multi-stage Builds**: Tối ưu hóa image Docker
- ✅ **Cấu Hình Nginx**: Định tuyến SPA + Proxy API
- ✅ **Tích Hợp MongoDB**: Database với Docker volume persistence

### 🏗️ Kiến Trúc
```
┌─────────────────┐
│  GitLab (Code)  │
│  10.32.4.111    │
└────────┬────────┘
         │ (Push/MR Events)
         ↓
┌─────────────────────────────────────┐
│  Jenkins Server (10.32.3.170)       │
│                                     │
│  [Build] → [Test] → [Push] → [Deploy] │
└──────────┬──────────────────┬───────┘
           │                  │
    Staging │                  │ Production
    (Auto)  ↓                  ↓ (Manual)
    10.32.3.172           10.32.3.173
```

### 📁 Cấu Trúc Dự Án
```
DevOps-main/
├── Backend/
│   ├── Dockerfile              # ← Container hóa
│   ├── .env.example           # ← Template config
│   └── server.js              # ← Express app
├── Frontend/
│   ├── Dockerfile             # ← Multi-stage build
│   ├── nginx.conf             # ← Định tuyến SPA
│   ├── .env.example           # ← Template config
│   └── src/                   # ← React app
├── Jenkinsfile                # ← 10-stage pipeline
├── docker-compose.yml         # ← Setup multi-container
├── SETUP_CHECKLIST.md         # ← Theo dõi cái này! 👈
├── JENKINS_SETUP.md           # ← Hướng dẫn chi tiết
└── quick-start.sh             # ← Test locally
```

## 🚀 Các Giai Đoạn Pipeline

```
Giai Đoạn 1: Checkout
  ↓
Giai Đoạn 2: Build Backend
  ↓
Giai Đoạn 3: Build Frontend
  ↓
Giai Đoạn 4: Test Backend
  ↓
Giai Đoạn 5: Phân Tích Chất Lượng (SonarQube)
  ↓
Giai Đoạn 6: Đẩy lên Docker Hub
  ↓
Giai Đoạn 7: Migration Database (Tùy chọn)
  ↓
Giai Đoạn 8: Triển Khai Staging (Tự động trên nhánh staging)
  ↓
Giai Đoạn 9: Smoke Tests
  ↓
Giai Đoạn 10: Triển Khai Production (Cần phê duyệt trên nhánh main)
```

## 🌿 Các Nhánh Git

| Nhánh | Trigger | Triển Khai Tới | Tự Động |
|--------|---------|-----------|------|
| develop | ❌ Không | - | ❌ |
| staging | ✅ Có | Staging | ✅ |
| main | ✅ Có | Production | ❌ Cần Phê Duyệt |

## ✅ Các Bước Cài Đặt

### Giai Đoạn 1: Test Local
```bash
chmod +x quick-start.sh
./quick-start.sh
```
**Kỳ Vọng**: Backend & Frontend chạy locally ✅

### Giai Đoạn 2: Server Jenkins
```bash
ssh root@10.32.3.170
chmod +x jenkins-server-setup.sh
./jenkins-server-setup.sh
```
**Kỳ Vọng**: Jenkins chạy tại http://10.32.3.170:8080 ✅

### Giai Đoạn 3: Cấu Hình
Theo dõi [SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md) để:
- Cài đặt Jenkins plugins
- Tạo credentials
- Cấu hình integrations
- Tạo pipeline job
- Setup GitLab webhook

**Kỳ Vọng**: Pipeline job sẵn sàng build ✅

### Giai Đoạn 4: Test Triển Khai
```bash
git push origin staging
```
Theo dõi Jenkins build → Triển khai tới staging ✅

## 📊 Điều Gì Được Build

### Backend Image
- **Base**: Node.js 18 Alpine
- **Kích Thước**: ~200MB
- **Services**: Express API, MongoDB connection
- **Port**: 80 (trong container), 8081 (trên host)

### Frontend Image
- **Base**: Nginx Alpine
- **Kích Thước**: ~150MB (được tối ưu multi-stage)
- **Tính Năng**: Định tuyến SPA, proxy API, gzip compression
- **Port**: 80

### Docker Compose Services
- Backend (Node.js Express)
- Frontend (Nginx + React)
- MongoDB (5.0 Alpine)
- Tất cả được kết nối thông qua bridge network

## 🔑 Các Tính Năng Chính Được Giải Thích

### Multi-stage Docker Build
```dockerfile
# Giai đoạn build (lớn)
FROM node:18-alpine
... npm install, build ...

# Giai đoạn cuối (nhỏ)
FROM nginx:alpine
COPY --from=builder /app/dist .
```
✅ Giảm kích thước image ~50%

### Cấu Hình Nginx
- Định tuyến SPA (phục vụ index.html cho tất cả routes)
- Proxy API tới backend
- Gzip compression
- Cache headers cho static files
- Security headers

### Orchestration
- Docker Compose cho local/server deployment
- Tất cả services trên same network
- Health checks cho mỗi container
- Volume persistence cho MongoDB

## 🔒 Bảo Mật

- ✅ Credentials lưu trữ trong Jenkins, không trong code
- ✅ SSH key-based server authentication
- ✅ .dockerignore loại trừ secrets
- ✅ Health checks ngăn chặn unhealthy deployments
- ✅ Manual approval cho production

## 📈 Monitoring

### Pipeline Success Rate
Theo dõi success rate - mục tiêu: >95%

### Deployment Time
- Build: ~3-5 phút
- Test: ~2-3 phút
- Deploy: ~1-2 phút
- **Tổng Cộng**: ~10-15 phút

### Server Health
```bash
# SSH tới server
ssh root@10.32.3.172

# Kiểm tra containers
docker ps
docker-compose ps

# Xem logs
docker-compose logs -f backend
docker-compose logs -f frontend

# Kiểm tra resources
docker stats
```

## 🆘 Khắc Phục Sự Cố

### Docker không khởi động
```bash
docker system prune -a --volumes
docker-compose up -d
```

### Build Jenkins fail
```bash
# Kiểm tra logs
tail -f /var/log/jenkins/jenkins.log

# Kiểm tra Docker
docker ps
docker logs jenkins
```

### Triển khai fail
```bash
# SSH tới server
ssh root@10.32.3.172

# Kiểm tra status
docker-compose ps
docker-compose logs

# Restart services
docker-compose restart
```

**Khắc Phục Chi Tiết**: Xem [CI-CD_COMPLETE_GUIDE.md](./CI-CD_COMPLETE_GUIDE.md#troubleshooting)

## 📝 File Cấu Hình

### Environment Variables
- `.env` - Level gốc (Docker Hub, etc)
- `Backend/.env` - Backend config (MongoDB, PORT)
- `Frontend/.env` - Frontend config (API URL)

### Docker
- `Dockerfile` - Backend: Node.js đơn giản
- `Dockerfile` - Frontend: Multi-stage Nginx
- `docker-compose.yml` - Orchestration
- `nginx.conf` - Frontend routing rules

### Pipeline
- `Jenkinsfile` - 10-stage pipeline definition
- `.gitignore` - Git ignore rules

## 🎓 Tài Liệu Học Tập

- Jenkins: https://www.jenkins.io/doc/
- Docker: https://docs.docker.com/
- GitLab: https://docs.gitlab.com/ee/ci/
- SonarQube: https://docs.sonarqube.org/

## 📞 Hỗ Trợ

1. **Không Hoạt Động?** → Kiểm Tra [SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md)
2. **Cần Chi Tiết?** → Đọc [CI-CD_COMPLETE_GUIDE.md](./CI-CD_COMPLETE_GUIDE.md)
3. **Setup Jenkins?** → Theo Dõi [JENKINS_SETUP.md](./JENKINS_SETUP.md)
4. **Tổng Quan?** → Xem [SETUP_SUMMARY.md](./SETUP_SUMMARY.md)

## ✨ Các Bước Tiếp Theo

- [ ] Đọc [SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md)
- [ ] Chạy `./quick-start.sh` để test locally
- [ ] Setup Jenkins server
- [ ] Cấu hình Jenkins (theo dõi checklist)
- [ ] Đẩy code để trigger pipeline
- [ ] Theo dõi deployment đầu tiên

## 📄 File Được Tạo

| Category | Count | Files |
|----------|-------|-------|
| Docker Config | 6 | Dockerfile, .dockerignore, docker-compose.yml, nginx.conf |
| Pipeline | 1 | Jenkinsfile |
| Configuration | 5 | .env templates, Backend/.env, Frontend/.env |
| Documentation | 4 | SETUP_*, JENKINS_SETUP, CI-CD_COMPLETE_GUIDE, README |
| Scripts | 4 | quick-start.sh, cleanup.sh, jenkins-server-setup.sh, deploy.sh |
| **Tổng Cộng** | **24** | **Setup Hoàn Chỉnh** |

## 🎉 Chỉ Báo Thành Công

Pipeline hoạt động khi:
- ✅ Docker images build thành công
- ✅ Images push lên Docker Hub
- ✅ Staging deployment hoàn tất
- ✅ Frontend tải tại http://10.32.3.172
- ✅ Backend API phản hồi tại http://10.32.3.172:8081
- ✅ SonarQube analysis hoàn tất
- ✅ Production deployment cần phê duyệt

## 📊 Benchmark Hiệu Năng

| Metric | Mục Tiêu | Hiện Tại |
|--------|---------|---------|
| Build Time | <10 phút | ~5-8 phút |
| Test Time | <5 phút | ~2-3 phút |
| Deploy Time | <2 phút | ~1-2 phút |
| Success Rate | >95% | Theo Dõi |
| Image Size | <300MB | ~350MB |

## 🚀 Production Checklist

Trước khi đi live:
- [ ] Test staging deployment 5+ lần
- [ ] Workflow phê duyệt manual được xác minh
- [ ] Rollback procedure được ghi chép
- [ ] Monitoring setup hoàn tất
- [ ] Alerting configured
- [ ] Team được train
- [ ] Backup strategy có sẵn
- [ ] Security review hoàn tất

## 📄 Giấy Phép

ISC

## 👥 Team

- Setup: DevOps Team
- Maintenance: Ops Team
- Support: DevOps Lead

---

**Sẵn Sàng Bắt Đầu? → [SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md)** 👈

**Câu Hỏi? → [CI-CD_COMPLETE_GUIDE.md](./CI-CD_COMPLETE_GUIDE.md)** 📖

---

**Phiên Bản**: 1.0.0  
**Trạng Thái**: ✅ Sản Xuất Sẵn Sàng  
**Cập Nhật Lần Cuối**: 2024
