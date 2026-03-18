<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
// ===== VERIFICAR ACCESO =====
// Solo clientes logueados pueden usar el formulario de contacto
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}
if ("admin".equals(session.getAttribute("tipo_usuario"))) {
    response.sendRedirect("Admin.jsp");
    return;
}

String mensaje = "";
String tipoMensaje = "";

// ===== PROCESAR FORMULARIO DE CONTACTO =====
if ("POST".equalsIgnoreCase(request.getMethod())) {
    
    // ===== OBTENER DATOS DEL FORMULARIO =====
    String nombre = request.getParameter("nombre");
    String email = request.getParameter("email");
    String telefono = request.getParameter("telefono");
    String asunto = request.getParameter("asunto");
    String mensajeTexto = request.getParameter("mensaje");
    String clienteId = (String) session.getAttribute("cliente_id");
    
    Connection con = null;
    PreparedStatement stmt = null;
    
    try {
        // ===== CONECTAR Y GUARDAR MENSAJE =====
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
        
        // Insertar mensaje en la tabla de contacto
        String sql = "INSERT INTO mensajes_contacto (id_cliente, nombre, email, telefono, asunto, mensaje) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        stmt = con.prepareStatement(sql);
        stmt.setString(1, clienteId);      // ID del cliente
        stmt.setString(2, nombre);         // Nombre del remitente
        stmt.setString(3, email);          // Email del remitente
        stmt.setString(4, telefono);       // Teléfono del remitente
        stmt.setString(5, asunto);         // Tipo de consulta
        stmt.setString(6, mensajeTexto);   // El mensaje en sí
        
        int filas = stmt.executeUpdate();
        
        if (filas > 0) {
            // ===== MENSAJE ENVIADO EXITOSAMENTE =====
            mensaje = "Tu mensaje ha sido enviado exitosamente. Te contactaremos pronto.";
            tipoMensaje = "success";
            
            // Limpiar campos del formulario
            nombre = "";
            email = "";
            telefono = "";
            mensajeTexto = "";
        }
        
    } catch (Exception e) {
        // ===== ERROR AL ENVIAR MENSAJE =====
        mensaje = "Error al enviar mensaje: " + e.getMessage();
        tipoMensaje = "error";
    } finally {
        // ===== LIMPIEZA =====
        if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Contacto - Sakura Bites</title>
    <link rel="stylesheet" href="CSS/styles.css">
</head>
<body>
    <!-- ===== ENCABEZADO ===== -->
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
        <h1>Contáctanos</h1>
        
        <!-- ===== MOSTRAR MENSAJE DE RESPUESTA ===== -->
        <% if (!mensaje.isEmpty()) { %>
            <div class="<%= tipoMensaje %>"><%= mensaje %></div>
        <% } %>
        
        <!-- ===== DISEÑO EN DOS COLUMNAS ===== -->
        <div class="grid-2">
            
            <!-- ===== COLUMNA 1: FORMULARIO DE CONTACTO ===== -->
            <div>
                <h2>Envíanos un mensaje</h2>
                <form method="post" action="Contacto.jsp">
                    
                    <!-- Información personal -->
                    <label for="nombre">Nombre:</label>
                    <input type="text" id="nombre" name="nombre" 
                           value="<%= session.getAttribute("nombre_usuario") != null ? session.getAttribute("nombre_usuario") : "" %>" required>
                    
                    <label for="email">Correo Electrónico:</label>
                    <input type="email" id="email" name="email" 
                           value="<%= session.getAttribute("usuario") %>" required>
                    
                    <label for="telefono">Teléfono:</label>
                    <input type="text" id="telefono" name="telefono">
                    
                    <!-- ===== TIPO DE CONSULTA ===== -->
                    <label for="asunto">Asunto:</label>
                    <select id="asunto" name="asunto" required>
                        <option value="">Seleccione...</option>
                        <option value="consulta">Consulta General</option>
                        <option value="pedido">Sobre mi Pedido</option>
                        <option value="sugerencia">Sugerencia</option>
                        <option value="reclamo">Reclamo</option>
                        <option value="eventos">Eventos y Catering</option>
                    </select>
                    
                    <!-- El mensaje en sí -->
                    <label for="mensaje">Mensaje:</label>
                    <textarea id="mensaje" name="mensaje" rows="5" required></textarea>
                    
                    <input type="submit" value="Enviar Mensaje">
                </form>
            </div>
            
            <!-- ===== COLUMNA 2: INFORMACIÓN DE CONTACTO ===== -->
            <div>
                <h2>Información de Contacto</h2>
                
                <div class="admin-panel">
                    <!-- Ubicación -->
                    <h3>📍 Ubicación</h3>
                    <p>Food Truck móvil en la Universidad Tecnológica de Panamá<br>
                    Consulta nuestras redes sociales para ubicación diaria</p>
                    
                    <!-- Información de contacto -->
                    <h3>📞 Teléfono</h3>
                    <p>+507 6521-9065</p>
                    
                    <h3>📧 Email</h3>
                    <p>sakurabites@sakura.com</p>
                    
                    <!-- Horarios de atención -->
                    <h3>🕒 Horario de Atención</h3>
                    <p>Lunes a Viernes: 11:00 AM - 8:00 PM<br>
                    Sábados y Domingos: 12:00 PM - 10:00 PM</p>
                    
                    <!-- Redes sociales -->
                    <h3>📱 Síguenos en Instagram!</h3>
                    <p> 
                        <a href="https://www.instagram.com/sakura_bites.truck/?utm_source=ig_web_button_share_sheet">Instagram</a>
                    </p>
                </div>
                
                <!-- ===== MAPA INTEGRADO ===== -->
                <!-- Mapa de Google Maps mostrando la ubicación en la UTP -->
                <div class="mapa-contenedor">
                    <iframe
                        src="https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d414.1881244263163!2d-79.53212187830877!3d9.023224753041001!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x8faca95e36ba599b%3A0x1df6f8d44f9f08fc!2sParque%20Pit%C3%A1goras%20UTP!5e0!3m2!1ses-419!2spa!4v1752806666332!5m2!1ses-419!2spa"
                        width="100%"
                        height="350"
                        style="border:0;"
                        allowfullscreen=""
                        loading="lazy"
                        referrerpolicy="no-referrer-when-downgrade">
                    </iframe>
                </div>
            </div>
        </div>
    </section>

    <!-- ===== PIE DE PÁGINA ===== -->
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