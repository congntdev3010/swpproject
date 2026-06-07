<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="/WEB-INF/jsp/header.jsp" %>

<main class="page-wrapper">

    <!-- ==================== ABOUT HERO ==================== -->
    <section class="about-hero">
        <div class="container" style="position:relative;z-index:1;">
            <div style="max-width:600px;">
                <div class="hero-eyebrow">
                    <i class="fa-solid fa-circle-info"></i>
                    Về chúng tôi
                </div>
                <h1 style="font-family:'Playfair Display',serif; font-size:clamp(1.8rem,3.5vw,2.8rem); font-weight:700; color:var(--text-primary); line-height:1.2; margin-bottom:16px;">
                    Thư viện FPT University
                </h1>
                <p style="font-size:1rem; color:var(--text-secondary); line-height:1.75; max-width:500px;">
                    Là trung tâm tri thức của cộng đồng FPT, chúng tôi cung cấp nguồn tài liệu
                    học thuật phong phú và môi trường học tập hiện đại.
                </p>
            </div>
        </div>
    </section>

    <!-- ==================== MISSION & VISION ==================== -->
    <section class="about-section">
        <div class="container">
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:40px; align-items:center;">
                <div>
                    <h2 class="section-title" style="margin-bottom:20px;">Sứ mệnh & Tầm nhìn</h2>
                    <p style="color:var(--text-secondary); line-height:1.8; margin-bottom:16px;">
                        <strong style="color:var(--text-primary);">Sứ mệnh:</strong>
                        Cung cấp môi trường học tập, nghiên cứu chất lượng cao thông qua hệ thống
                        tài liệu phong phú, dịch vụ chuyên nghiệp và công nghệ hiện đại, góp phần
                        thúc đẩy sự phát triển tri thức của sinh viên và giảng viên FPT University.
                    </p>
                    <p style="color:var(--text-secondary); line-height:1.8;">
                        <strong style="color:var(--text-primary);">Tầm nhìn:</strong>
                        Trở thành thư viện đại học hàng đầu Việt Nam, nơi mọi thành viên FPT
                        đều có thể tiếp cận tri thức toàn cầu một cách dễ dàng và hiệu quả.
                    </p>
                </div>
                <div class="info-grid" style="grid-template-columns:1fr 1fr;">
                    <div class="info-card" style="text-align:center;">
                        <div style="font-size:2rem; font-weight:800; color:var(--primary); margin-bottom:4px;">300+</div>
                        <div style="font-size:0.85rem; color:var(--text-muted);">Đầu sách học thuật</div>
                    </div>
                    <div class="info-card" style="text-align:center;">
                        <div style="font-size:2rem; font-weight:800; color:var(--accent); margin-bottom:4px;">5</div>
                        <div style="font-size:0.85rem; color:var(--text-muted);">Danh mục chuyên ngành</div>
                    </div>
                    <div class="info-card" style="text-align:center;">
                        <div style="font-size:2rem; font-weight:800; color:var(--success); margin-bottom:4px;">50+</div>
                        <div style="font-size:0.85rem; color:var(--text-muted);">Tác giả trong nước & quốc tế</div>
                    </div>
                    <div class="info-card" style="text-align:center;">
                        <div style="font-size:2rem; font-weight:800; color:var(--info); margin-bottom:4px;">24/7</div>
                        <div style="font-size:0.85rem; color:var(--text-muted);">Tra cứu trực tuyến</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ==================== CORE VALUES ==================== -->
    <section class="about-section" style="background:var(--bg-card); border-top:1px solid var(--border); border-bottom:1px solid var(--border);">
        <div class="container">
            <div style="text-align:center; margin-bottom:40px;">
                <h2 class="section-title" style="display:inline-block;">Giá trị cốt lõi</h2>
            </div>
            <div class="info-grid">
                <div class="info-card">
                    <div class="info-card-icon">🎯</div>
                    <h3>Chính xác & Tin cậy</h3>
                    <p>Mọi thông tin về sách, trạng thái và vị trí đều được cập nhật chính xác, kịp thời.</p>
                </div>
                <div class="info-card">
                    <div class="info-card-icon">🤝</div>
                    <h3>Phục vụ tận tâm</h3>
                    <p>Đội ngũ thủ thư nhiệt tình, sẵn sàng hỗ trợ sinh viên tìm kiếm tài liệu học tập.</p>
                </div>
                <div class="info-card">
                    <div class="info-card-icon">💡</div>
                    <h3>Đổi mới liên tục</h3>
                    <p>Ứng dụng công nghệ số để nâng cao trải nghiệm người dùng và hiệu quả quản lý.</p>
                </div>
                <div class="info-card">
                    <div class="info-card-icon">🌱</div>
                    <h3>Phát triển bền vững</h3>
                    <p>Không ngừng bổ sung tài liệu mới, đáp ứng nhu cầu học tập và nghiên cứu ngày càng cao.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- ==================== HOURS & LOCATION ==================== -->
    <section class="about-section">
        <div class="container">
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:40px;">
                <!-- Hours -->
                <div>
                    <h2 class="section-title" style="margin-bottom:24px;">Giờ hoạt động</h2>
                    <div style="display:flex; flex-direction:column; gap:12px;">
                        <div style="display:flex; justify-content:space-between; align-items:center; padding:14px 18px; background:var(--bg-surface); border:1px solid var(--border); border-radius:var(--radius-sm);">
                            <span style="font-weight:600; color:var(--text-primary);">Thứ 2 – Thứ 6</span>
                            <span class="badge badge-success">7:30 – 20:00</span>
                        </div>
                        <div style="display:flex; justify-content:space-between; align-items:center; padding:14px 18px; background:var(--bg-surface); border:1px solid var(--border); border-radius:var(--radius-sm);">
                            <span style="font-weight:600; color:var(--text-primary);">Thứ 7</span>
                            <span class="badge badge-info">7:30 – 17:30</span>
                        </div>
                        <div style="display:flex; justify-content:space-between; align-items:center; padding:14px 18px; background:var(--bg-surface); border:1px solid var(--border); border-radius:var(--radius-sm);">
                            <span style="font-weight:600; color:var(--text-primary);">Chủ nhật & Lễ</span>
                            <span class="badge badge-danger">Đóng cửa</span>
                        </div>
                        <div style="padding:14px 18px; background:rgba(245,158,11,0.06); border:1px solid rgba(245,158,11,0.2); border-radius:var(--radius-sm);">
                            <div style="font-size:0.85rem; color:var(--warning);">
                                <i class="fa-solid fa-circle-info fa-xs"></i>
                                <strong>Tra cứu trực tuyến</strong> hoạt động 24/7 qua hệ thống này.
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Contact -->
                <div>
                    <h2 class="section-title" style="margin-bottom:24px;">Thông tin liên hệ</h2>
                    <div style="display:flex; flex-direction:column; gap:12px;">
                        <div class="contact-item">
                            <div class="ci-icon"><i class="fa-solid fa-location-dot"></i></div>
                            <div>
                                <div class="ci-label">Địa chỉ</div>
                                <div class="ci-value">Lô E2a-7, Đường D1, Khu Công nghệ cao, P. Long Thạnh Mỹ, Q.9, TP.HCM</div>
                            </div>
                        </div>
                        <div class="contact-item">
                            <div class="ci-icon"><i class="fa-solid fa-phone"></i></div>
                            <div>
                                <div class="ci-label">Điện thoại</div>
                                <div class="ci-value">(028) 7300 5588 – Ext. 123</div>
                            </div>
                        </div>
                        <div class="contact-item">
                            <div class="ci-icon"><i class="fa-solid fa-envelope"></i></div>
                            <div>
                                <div class="ci-label">Email</div>
                                <div class="ci-value">library@fpt.edu.vn</div>
                            </div>
                        </div>
                        <div class="contact-item">
                            <div class="ci-icon"><i class="fa-solid fa-building"></i></div>
                            <div>
                                <div class="ci-label">Cơ sở</div>
                                <div class="ci-value">Tòa nhà thư viện – Tầng 1 &amp; 2, FPT University HCM</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ==================== MAP ==================== -->
    <section style="padding: 0;">
        <div style="height:320px; background:var(--bg-surface); border-top:1px solid var(--border); position:relative; overflow:hidden;">
            <iframe
                src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3918.609!2d106.807457!3d10.841320!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x31752731176b07b1%3A0xb752b24b379bae5e!2sFPT%20University%20HCMC!5e0!3m2!1sen!2s!4v1625000000000"
                width="100%" height="320"
                style="border:0; filter:invert(90%) hue-rotate(180deg); opacity:0.85;"
                allowfullscreen="" loading="lazy"
                referrerpolicy="no-referrer-when-downgrade"
                title="Bản đồ FPT University HCM">
            </iframe>
        </div>
    </section>

</main>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>

<style>
@media (max-width: 768px) {
    .about-section > .container > div[style*="grid-template-columns:1fr 1fr"] {
        grid-template-columns: 1fr !important;
    }
}
</style>
