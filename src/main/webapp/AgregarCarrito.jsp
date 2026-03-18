<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
// ===== VERIFICAR QUE EL USUARIO ESTÉ LOGUEADO =====
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

// ===== OBTENER DATOS DEL FORMULARIO Y SESIÓN =====
String idProducto = request.getParameter("id_producto");  // ¿Qué producto agregar?
String idUsuario = (String) session.getAttribute("usuario_id");  // ¿Quién lo está agregando?
String mensaje = "";
boolean exito = false;

// ===== VERIFICAR QUE TENEMOS LOS DATOS NECESARIOS =====
if (idProducto != null && idUsuario != null) {
    
    // ===== VARIABLES PARA BASE DE DATOS =====
    Connection con = null;
    PreparedStatement stmtVerificar = null;    // Para verificar si ya existe
    PreparedStatement stmtInsertar = null;     // Para insertar nuevo
    PreparedStatement stmtActualizar = null;   // Para actualizar cantidad
    ResultSet rs = null;
    
    try {
        // ===== CONECTAR A LA BASE DE DATOS =====
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
        
        // ===== VERIFICAR SI EL PRODUCTO YA ESTÁ EN EL CARRITO =====
        // Primero revisamos si este usuario ya tiene este producto en su carrito
        String sqlVerificar = "SELECT id_carrito, cantidad FROM carrito WHERE id_usuario = ? AND id_producto = ?";
        stmtVerificar = con.prepareStatement(sqlVerificar);
        stmtVerificar.setString(1, idUsuario);
        stmtVerificar.setString(2, idProducto);
        rs = stmtVerificar.executeQuery();
        
        if (rs.next()) {
            // ===== EL PRODUCTO YA EXISTE - AUMENTAR CANTIDAD =====
            int cantidadActual = rs.getInt("cantidad");  // Cantidad actual
            int idCarrito = rs.getInt("id_carrito");     // ID del registro en el carrito
            
            // Actualizar la cantidad (aumentar en 1) y la fecha
            String sqlActualizar = "UPDATE carrito SET cantidad = ?, fecha_agregado = CURRENT_TIMESTAMP WHERE id_carrito = ?";
            stmtActualizar = con.prepareStatement(sqlActualizar);
            stmtActualizar.setInt(1, cantidadActual + 1);  // Cantidad actual + 1
            stmtActualizar.setInt(2, idCarrito);
            stmtActualizar.executeUpdate();
            
            mensaje = "Producto actualizado en el carrito";
            
        } else {
            // ===== EL PRODUCTO NO EXISTE - INSERTAR NUEVO =====
            String sqlInsertar = "INSERT INTO carrito (id_usuario, id_producto, cantidad) VALUES (?, ?, 1)";
            stmtInsertar = con.prepareStatement(sqlInsertar);
            stmtInsertar.setString(1, idUsuario);
            stmtInsertar.setString(2, idProducto);
            // La cantidad inicial es 1
            stmtInsertar.executeUpdate();
            
            mensaje = "Producto agregado al carrito";
        }
        
        exito = true;  // Todo salió bien
        
    } catch (Exception e) {
        // ===== MANEJO DE ERRORES =====
        mensaje = "Error al agregar al carrito: " + e.getMessage();
    } finally {
        // ===== LIMPIEZA DE CONEXIONES =====
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (stmtVerificar != null) try { stmtVerificar.close(); } catch (SQLException e) {}
        if (stmtInsertar != null) try { stmtInsertar.close(); } catch (SQLException e) {}
        if (stmtActualizar != null) try { stmtActualizar.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Agregar al Carrito - Sakura Bites</title>
    <link rel="stylesheet" href="CSS/styles.css">
    <!-- Si todo salió bien, redirigir automáticamente al carrito -->
    <% if (exito) { %>
        <meta http-equiv="refresh" content="1;url=Carrito.jsp">
    <% } %>
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

    <!-- ===== MENSAJE DE CONFIRMACIÓN ===== -->
    <section class="text-center">
        <% if (exito) { %>
            <!-- Mensaje de éxito -->
            <div class="success">
                <h2>✓ <%= mensaje %></h2>
                <p>Redirigiendo al carrito...</p>
            </div>
        <% } else { %>
            <!-- Mensaje de error -->
            <div class="error">
                <h2>✗ Error</h2>
                <p><%= mensaje %></p>
            </div>
        <% } %>
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