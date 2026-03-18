<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
String mensaje = ""; // Para mostrar mensajes de error o éxito

// ===== PROCESAR LOGIN CUANDO SE ENVÍA EL FORMULARIO =====
if ("POST".equalsIgnoreCase(request.getMethod())) {
    
    // Obtener credenciales del formulario
    String correo = request.getParameter("correo");
    String clave = request.getParameter("clave");
    
    // Variables para trabajar con la base de datos
    Connection con = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        // ===== CONECTAR A LA BASE DE DATOS =====
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
        
        // ===== BUSCAR AL USUARIO =====
        // Buscamos en la tabla usuarios y obtenemos también datos del cliente si existe
        String sql = "SELECT u.*, c.nombre, c.id_cliente FROM usuarios u " +
                     "LEFT JOIN clientes c ON u.id_usuario = c.id_usuario " +
                     "WHERE u.correo = ? AND u.clave = ? AND u.activo = TRUE";
        
        stmt = con.prepareStatement(sql);
        stmt.setString(1, correo);  // Email ingresado
        stmt.setString(2, clave);   // Contraseña ingresada
        
        rs = stmt.executeQuery();
        
        // ===== VERIFICAR SI SE ENCONTRÓ AL USUARIO =====
        if (rs.next()) {
            // ¡LOGIN EXITOSO! 
            
            // ===== CREAR SESIÓN =====
            // Guardamos información importante en la sesión del usuario
            session.setAttribute("usuario", correo);                           // Email del usuario
            session.setAttribute("usuario_id", rs.getString("id_usuario"));    // ID único del usuario
            session.setAttribute("tipo_usuario", rs.getString("tipo_usuario"));// "cliente" o "admin"
            
            // ===== REDIRIGIR SEGÚN EL TIPO DE USUARIO =====
            if ("cliente".equals(rs.getString("tipo_usuario"))) {
                // Si es cliente, guardar información adicional
                session.setAttribute("cliente_id", rs.getString("id_cliente"));
                session.setAttribute("nombre_usuario", rs.getString("nombre"));
                response.sendRedirect("HomeCliente.jsp"); // Enviar al panel de cliente
            } else {
                // Si es admin, enviar al panel de administración
                response.sendRedirect("Admin.jsp");
            }
            return; // Terminar la ejecución aquí
            
        } else {
            // ===== CREDENCIALES INCORRECTAS =====
            mensaje = "Correo o contraseña incorrectos";
        }
        
    } catch (Exception e) {
        // ===== ERROR DE CONEXIÓN O SISTEMA =====
        mensaje = "Error al conectar: " + e.getMessage();
    } finally {
        // ===== LIMPIEZA - CERRAR CONEXIONES =====
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login - Sakura Bites</title>
    <link rel="stylesheet" href="CSS/styles.css">
</head>
<body>
    <!-- ===== ENCABEZADO ===== -->
    <header>
        <h1>🌸 Sakura Bites 🌸</h1>
        <nav>
            <img src="Imagenes/LogoSakuraBites.png" alt="Logo Sakura Bites" width="100">
            <a href="home.jsp">Inicio</a>
            <a href="Nosotros.jsp">Sobre Nosotros</a>
            <a href="Menu.jsp">Menú</a>
            <a href="login.jsp">Login</a>
            <a href="Registro.jsp">Registro</a>
            <a href="https://www.google.com" target="_blank">🔍</a>
        </nav>
    </header>

    <!-- ===== CONTENIDO PRINCIPAL ===== -->
    <section>
        <h1>Iniciar Sesión</h1>
        
        <!-- Mostrar mensaje de error si las credenciales son incorrectas -->
        <% if (!mensaje.isEmpty()) { %>
            <div class="error"><%= mensaje %></div>
        <% } %>
        
        <!-- ===== FORMULARIO DE LOGIN ===== -->
        <form method="post" action="login.jsp">
            <!-- Campo para el email -->
            <label for="correo">Correo Electrónico:</label>
            <input type="email" id="correo" name="correo" required>
            
            <!-- Campo para la contraseña -->
            <label for="clave">Contraseña:</label>
            <input type="password" id="clave" name="clave" required>
            
            <!-- Botón para enviar -->
            <input type="submit" value="Iniciar Sesión">
        </form>
        
        <!-- Link para registrarse si no tienen cuenta -->
        <p>¿No tienes cuenta? <a href="Registro.jsp">Regístrate aquí</a></p>
    </section>

    <!-- ===== PIE DE PÁGINA ===== -->
    <footer>
        <nav>
            <a href="home.jsp">Inicio</a> |
            <a href="Nosotros.jsp">Sobre Nosotros</a> |
            <a href="Menu.jsp">Menú</a> |
            <a href="Logout.jsp">Logout</a>
        </nav>
        <p>&copy; 2025 Sakura Bites. Todos los derechos reservados.</p>
    </footer>
</body>
</html>
