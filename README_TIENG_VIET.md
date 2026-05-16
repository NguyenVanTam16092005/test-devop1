# 📚 HƯỚNG DẪN JENKINS CI/CD PIPELINE - TIẾNG VIỆT

## 🎯 BƯỚC BẮT ĐẦU NHANH

### Bước 1: Test Local (5 phút)
```bash
# Copy cấu hình
cp .env.example .env
cp Backend/.env.example Backend/.env
cp Frontend/.env.example Frontend/.env

# Chạy
chmod +x quick-start.sh
./quick-start.sh

# Truy cập
# Frontend: http://localhost
# Backend:  http://localhost:8081
```

### Bước 2: Setup Jenkins (30 phút)
```bash
# SSH tới Jenkins server
ssh root@10.32.3.170

# Chạy automated setup
chmod +x jenkins-server-setup.sh
./jenkins-server-setup.sh

# Truy cập Jenkins
# http://10.32.3.170:8080
```

### Bước 3: Cấu Hình Jenkins
👉 **Theo dõi file SETUP_CHECKLIST.md**

### Bước 4: Deploy
```bash
# Push tới staging (tự động deploy)
git push origin staging

# Push tới main (cần phê duyệt production)
git push origin main
```

---

## 📁 CÂU TRÚC FILE TẠO RA

```
✅ 6 File Docker Config
   - Backend/Dockerfile
   - Frontend/Dockerfile
   - Frontend/nginx.conf
   - docker-compose.yml
   - Các .dockerignore files

✅ 1 File Pipeline
   - Jenkinsfile (10 giai đoạn)

✅ 5 File Config
   - .env.example
   - Backend/.env.example
   - Frontend/.env.example
   - .env.docker
   - deploy.sh

✅ 4 Script Helper
   - quick-start.sh
   - cleanup.sh
   - jenkins-server-setup.sh
   - deploy.sh

✅ 5 File Tài Liệu
   - CICD_README.md
   - SETUP_SUMMARY.md
   - SETUP_CHECKLIST.md
   - JENKINS_SETUP.md
   - CI-CD_COMPLETE_GUIDE.md
```

---

## 🚀 PIPELINE 10 GIAI ĐOẠN

1. **Checkout**: Lấy code từ GitLab
2. **Build Backend**: Tạo Docker image Backend
3. **Build Frontend**: Tạo Docker image Frontend
4. **Test Backend**: Chạy unit tests
5. **SonarQube**: Phân tích chất lượng code
6. **Push Docker Hub**: Đẩy images lên registry
7. **DB Migration**: Migration database (tùy chọn)
8. **Deploy Staging**: Triển khai Staging (tự động)
9. **Smoke Tests**: Kiểm tra services
10. **Deploy Production**: Triển khai Production (cần duyệt)

---

## 🌿 NHÁNH GIT

| Nhánh | Trigger | Deploy Tới | Tự Động |
|-------|---------|-----------|---------|
| develop | ❌ | - | ❌ |
| staging | ✅ | Staging Server | ✅ |
| main | ✅ | Production Server | ❌ Cần Duyệt |

---

## 🏗️ KIẾN TRÚC HỆBỔ

```
GitLab (10.32.4.111:8090)
    ↓
Jenkins (10.32.3.170:8080)
    ├─ Build images
    ├─ Test code
    ├─ Push Docker Hub
    └─ Deploy servers
        ├─ Staging: 10.32.3.172
        └─ Production: 10.32.3.173
```

---

## 📊 THỜI GIAN BUILD

- Build: 5-8 phút
- Test: 2-3 phút
- Deploy: 1-2 phút
- **Tổng**: 10-15 phút

---

## ✅ KIỂM TRA HOÀN THÀNH

Khi hoàn thành:
- ✅ Docker chạy local
- ✅ Jenkins server online
- ✅ Plugins installed
- ✅ Credentials configured
- ✅ Pipeline job created
- ✅ GitLab webhook active
- ✅ Staging deploy works
- ✅ Production deploy works
- ✅ Images on Docker Hub
- ✅ SonarQube runs

---

## 🔍 KIỂM TRA TÌNH TRẠNG SERVER

```bash
# SSH tới server
ssh root@10.32.3.172

# Xem containers
docker-compose ps

# Xem logs
docker-compose logs -f

# Test endpoints
curl http://localhost:8081/api/students
curl http://localhost
```

---

## 🆘 KHẮC PHỤC NHANH

```bash
# Cleanup & restart
docker-compose down
docker-compose up -d

# Xem logs
docker-compose logs -f backend

# Reset
docker system prune -a --volumes
```

---

## 📝 FILE QUAN TRỌNG

**Đọc theo thứ tự:**
1. CICD_README.md (tổng quan)
2. SETUP_CHECKLIST.md (hướng dẫn chi tiết)
3. JENKINS_SETUP.md (cập hình Jenkins)
4. CI-CD_COMPLETE_GUIDE.md (tham khảo đầy đủ)

---

## 🎯 HỌC TIẾP THEO

1. Đọc CICD_README.md
2. Chạy quick-start.sh
3. Setup Jenkins server
4. Follow SETUP_CHECKLIST.md
5. Test staging deploy
6. Test production deploy

---

**Tất cả code sẵn sàng! Hãy bắt đầu đi!** 🚀
