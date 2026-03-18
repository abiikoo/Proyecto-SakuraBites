<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
// ===== CONTROL DE ACCESO =====
// Solo clientes logueados pueden ver su carrito
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}
if ("admin".equals(session.getAttribute("tipo_usuario"))) {
    response.sendRedirect("Admin.jsp");  // Los admins no tienen carrito
    return;
}

String idUsuario = (String) session.getAttribute("usuario_id");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Carrito de Compras - Sakura Bites</title>
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
        <h1>Mi Carrito</h1>
        
        <%
        // ===== VARIABLES PARA EL CARRITO =====
        Connection con = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        double total = 0;               // Total del carrito
        boolean hayProductos = false;   // ¿Hay productos en el carrito?
        
        try {
            // ===== CONECTAR Y OBTENER PRODUCTOS DEL CARRITO =====
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
            
            // Consulta que une carrito con productos para obtener toda la información
            String sql = "SELECT c.*, p.nombre, p.descripcion, p.precio " +
                        "FROM carrito c " +
                        "JOIN productos p ON c.id_producto = p.id_producto " +
                        "WHERE c.id_usuario = ?";
            stmt = con.prepareStatement(sql);
            stmt.setString(1, idUsuario);  // Solo productos de este usuario
            rs = stmt.executeQuery();
            
            // ===== VERIFICAR SI EL CARRITO ESTÁ VACÍO =====
            if (!rs.isBeforeFirst()) {  // No hay resultados
        %>
                <p>Tu carrito está vacío. <a href="Menu.jsp">Ver menú</a></p>
        <% 
            } else {
                hayProductos = true;  // Hay productos, mostrar tabla
        %>
                <!-- ===== TABLA DE PRODUCTOS EN EL CARRITO ===== -->
                <table>
                    <tr>
                        <th>Producto</th>
                        <th>Descripción</th>
                        <th>Precio</th>
                        <th>Cantidad</th>
                        <th>Subtotal</th>
                        <th>Acción</th>
                    </tr>
                    <%
                    // ===== MOSTRAR CADA PRODUCTO =====
                    while (rs.next()) {
                        double precio = rs.getDouble("precio");
                        int cantidad = rs.getInt("cantidad");
                        double subtotal = precio * cantidad;  // Calcular subtotal
                        total += subtotal;  // Sumar al total general
                    %>
                    <tr>
                        <td><%= rs.getString("nombre") %></td>
                        <td><%= rs.getString("descripcion") %></td>
                        <td>$<%= String.format("%.2f", precio) %></td>
                        <td><%= cantidad %></td>
                        <td>$<%= String.format("%.2f", subtotal) %></td>
                        <td>
                            <!-- Botón para eliminar producto del carrito -->
                            <form action="eliminarCarrito.jsp" method="post" class="inline">
                                <input type="hidden" name="id_carrito" value="<%= rs.getInt("id_carrito") %>">
                                <input type="submit" value="Eliminar">
                            </form>
                        </td>
                    </tr>
                    <% } %>
                    <!-- Fila del total -->
                    <tr>
                        <td colspan="4"><strong>Total:</strong></td>
                        <td colspan="2"><strong>$<%= String.format("%.2f", total) %></strong></td>
                    </tr>
                </table>
                
                <!-- ===== BOTONES DE ACCIÓN ===== -->
                <div class="mt-20">
                    <a href="Menu.jsp"><button>Seguir Comprando</button></a>
                    <a href="Checkout.jsp"><button>Proceder al Pago</button></a>
                </div>
        <% }
        } catch (Exception e) {
            // ===== MANEJO DE ERRORES =====
            out.println("<p class='error'>Error al cargar carrito: " + e.getMessage() + "</p>");
        } finally {
            // ===== LIMPIEZA DE CONEXIONES =====
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (con != null) try { con.close(); } catch (SQLException e) {}
        }
        %>
        
        <!-- ===== NOTA INFORMATIVA ===== -->
        <div class="mt-30 admin-panel">
            <p><strong>Nota:</strong> Las opciones del pedido se agregan al campo de descripción.</p>
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