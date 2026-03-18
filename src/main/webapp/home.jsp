<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Inicio - Sakura Bites</title>
    <link rel="stylesheet" href="CSS/styles.css">
</head>
<body>
    <header>
    <h1>🌸 Sakura Bites 🌸</h1>
        <nav>
            <img src="Imagenes/LogoSakuraBites.png" alt="Logo Sakura Bites" class="logo" width="100">
            <a href="home.jsp">Inicio</a>
            <a href="Nosotros.jsp">Sobre Nosotros</a>
            <a href="Menu.jsp">Menú</a>
            <a href="login.jsp">Login</a>
            <a href="Registro.jsp">Registro</a>
            <a href="https://www.google.com" target="_blank">🔍</a>
        </nav>
    </header>

    <section>
        <h1>¡Bienvenido a Sakura Bites!</h1>
        <p>Descubre los auténticos sabores de Asia en nuestro food truck. Especialistas en comida japonesa y coreana.</p>

        <!-- Información para visitantes -->
        <div class="bienvenida-section">
            <h3>🌸 ¿Primera vez aquí?</h3>
            <p>Explora nuestro menú y regístrate para realizar pedidos. ¡Únete a la familia Sakura Bites!</p>
            <a href="Menu.jsp"><button>Ver Menú</button></a>
            <a href="Registro.jsp"><button>Registrarse</button></a>
        </div>

        <h2>Noticias</h2>

        <div class="noticias-grid">
            <article class="noticia-card">
                <img src="Imagenes/comidajaponesa.jpg" alt="Gastronomía japonesa" class="noticia-img">
                <h3>🎌 Cultura japonesa en auge</h3>
                <p>Descubre cómo la gastronomía japonesa ha conquistado el mundo con sus sabores únicos y presentación artística.</p>
                <p class="noticia-link"><a href="https://es.wikipedia.org/wiki/Gastronomía_de_Japón" target="_blank">Leer más</a></p>
            </article>

            <article class="noticia-card">
                <img src="Imagenes/comidacoreana.jpg" alt="Street food" class="noticia-img">
                <h3>🎉 Street food: Tendencia mundial</h3>
                <p>Los food trucks están revolucionando la forma de disfrutar comida de calidad. Conoce más sobre esta tendencia.</p>
                <p class="noticia-link"><a href="https://es.wikipedia.org/wiki/Comida_callejera" target="_blank">Leer más</a></p>
            </article>

            <article class="noticia-card">
                <img src="Imagenes/dango.jpg" alt="Dango japonés" class="noticia-img">
                <h3>🎥 ¿Qué es un Dango? (Video)</h3>
                <p>Aprende sobre este tradicional dulce japonés que inspira nuestra paleta de colores.</p>
                <p class="noticia-link"><a href="https://www.youtube.com/shorts/rxwOcRe7KVQ" target="_blank">Ver video</a></p>
            </article>
        </div>

        <!-- Información del food truck -->
        <div class="info-grid">
            <div class="producto-card">
                <h3>📍 Ubicación</h3>
                <p>Parque Pitágoras en la Universidad Tecnológica de Panamá</p>
            </div>

            <div class="producto-card">
                <h3>🕒 Horarios</h3>
                <p>Lunes a Viernes: 11:00 AM - 9:00 PM<br>
                Sábados y Domingos: 12:00 PM - 10:00 PM</p>
            </div>

            <div class="producto-card">
                <h3>🍱 Especialidades</h3>
                <p>Ramen auténtico, sushi rolls creativos, bibimbap, bulgogi y mucho más.</p>
            </div>
        </div>
    </section>

    <footer>
        <nav>
            <a href="home.jsp">Inicio</a> |
            <a href="Nosotros.jsp">Sobre Nosotros</a> |
            <a href="Menu.jsp">Menú</a> |
            <a href="login.jsp">Login</a>
        </nav>
        <p>&copy; 2025 Sakura Bites. Todos los derechos reservados.</p>
    </footer>
</body>
</html>