<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%
// Verificar si el usuario está logueado
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}
// Si es admin, redirigir al panel de admin
if ("admin".equals(session.getAttribute("tipo_usuario"))) {
    response.sendRedirect("Admin.jsp");
    return;
}
%>
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
<img src="Imagenes/LogoSakuraBites.png" alt="Logo Sakura Bites" width="100">
<a href="HomeCliente.jsp">Inicio</a>
<a href="Menu.jsp">Menú</a>
<a href="ConsultarPedido.jsp">Mis Pedidos</a>
<a href="Carrito.jsp">Carrito</a>
<a href="Contacto.jsp">Contacto</a>
<a href="https://www.google.com" target="_blank">🔍</a>
</nav>
</header>

<section>
<h1>¡Bienvenido a Sakura Bites!</h1>
<p>Hola <%= session.getAttribute("nombre_usuario") != null ? session.getAttribute("nombre_usuario") : session.getAttribute("usuario") %>, gracias por elegirnos.</p>

<h2>Acciones Rápidas</h2>
<div class="grid-3 mb-20">
    <div class="producto-card">
        <h3>🍱 Ver Menú</h3>
        <p>Explora nuestros deliciosos platos japoneses y coreanos</p>
        <a href="Menu.jsp"><button>Ver Menú Completo</button></a>
    </div>
    
    <div class="producto-card">
        <h3>📋 Mis Pedidos</h3>
        <p>Revisa el estado de tus pedidos anteriores</p>
        <a href="ConsultarPedido.jsp"><button>Ver Mis Pedidos</button></a>
    </div>
    
    <div class="producto-card">
        <h3>🛒 Mi Carrito</h3>
        <p>Revisa los productos en tu carrito</p>
        <a href="Carrito.jsp"><button>Ir al Carrito</button></a>
    </div>
</div>

<h2>Noticias y Promociones</h2>
<div class="noticias-grid">
    <article class="noticia-card">
        <img src="Imagenes/rollo.jpg" alt="rollo sakura" class="noticia-img">
        <h3>🎌 Nuevos platos de temporada</h3>
        <p>Descubre nuestros nuevos rolls de sakura, perfectos para la primavera.</p>
        <p class="noticia-link"><a href="Menu.jsp" target="_blank">Ver más</a></p>
    </article>

    <article class="noticia-card">
        <img src="Imagenes/descuento.jpg" alt="descuento" class="noticia-img">
        <h3>🎉 Descuentos del 15% en pedidos para llevar!</h3>
        <p>Esta semana, todos los pedidos para llevar tienen 15% de descuento.</p>
        <p class="noticia-link"><a href="Menu.jsp" target="_blank">Ordenar ahora</a></p>
    </article>

    <article class="noticia-card">
        <img src="Imagenes/palillos.jpg" alt="palillos" class="noticia-img">
        <h3>🎥 Tutorial: Cómo usar palillos correctamente (Video)</h3>
        <p>Aprende cómo usar palillos de forma adecuada con este video tutorial.</p>
        <p class="noticia-link"><a href="https://www.youtube.com/watch?v=Gc3sYsBqnYo" target="_blank">Ver video</a></p>
    </article>
</div>
</section>

<footer>
<nav>
<a href="HomeCliente.jsp">Inicio</a> |
<a href="Menu.jsp">Menú</a> |
<a href="ConsultarPedido.jsp">Mis Pedidos</a> |
<a href="Logout.jsp">Logout</a>
</nav>
<p>&copy; 2025 Sakura Bites. Todos los derechos reservados.</p>
</footer>
</body>
</html>