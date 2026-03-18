<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
// Verificar que el usuario esté logueado
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

String idPedido = request.getParameter("id");
String clienteId = (String) session.getAttribute("cliente_id");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Detalle del Pedido - Sakura Bites</title>
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
        <h1>Detalle del Pedido #<%= idPedido %></h1>
        
        <%
        Connection con = null;
        PreparedStatement stmtPedido = null;
        PreparedStatement stmtDetalle = null;
        ResultSet rsPedido = null;
        ResultSet rsDetalle = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
            
            // Obtener información del pedido
            String sqlPedido = "SELECT * FROM pedidos WHERE id_pedido = ? AND cliente_id = ?";
            stmtPedido = con.prepareStatement(sqlPedido);
            stmtPedido.setString(1, idPedido);
            stmtPedido.setString(2, clienteId);
            rsPedido = stmtPedido.executeQuery();
            
            if (rsPedido.next()) {
                String estado = rsPedido.getString("estado");
                String claseEstado = "";
                if ("completado".equals(estado)) claseEstado = "success";
                else if ("cancelado".equals(estado)) claseEstado = "error";
                else if ("en_preparacion".equals(estado)) claseEstado = "warning";
        %>
                <div class="admin-panel mb-20">
                    <h2>Información del Pedido</h2>
                    <p><strong>Fecha:</strong> <%= rsPedido.getTimestamp("fecha") %></p>
                    <p><strong>Estado:</strong> <span class="<%= claseEstado %>"><%= estado %></span></p>
                    <p><strong>Total:</strong> $<%= String.format("%.2f", rsPedido.getDouble("total")) %></p>
                    <p><strong>Método de Pago:</strong> <%= rsPedido.getString("metodo_pago") %></p>
                    <p><strong>Tipo de Pedido:</strong> <%= rsPedido.getString("tipo_pedido") %></p>
                    <% if (rsPedido.getString("direccion_entrega") != null) { %>
                        <p><strong>Dirección de Entrega:</strong> <%= rsPedido.getString("direccion_entrega") %></p>
                    <% } %>
                    <% if (rsPedido.getString("notas") != null) { %>
                        <p><strong>Notas:</strong> <%= rsPedido.getString("notas") %></p>
                    <% } %>
                </div>
                
                <h2>Productos del Pedido</h2>
                <table>
                    <tr>
                        <th>Producto</th>
                        <th>Cantidad</th>
                        <th>Precio Unitario</th>
                        <th>Subtotal</th>
                    </tr>
                    <%
                    // Obtener detalles del pedido
                    String sqlDetalle = "SELECT dp.*, p.nombre FROM detalle_pedidos dp " +
                                       "JOIN productos p ON dp.id_producto = p.id_producto " +
                                       "WHERE dp.id_pedido = ?";
                    stmtDetalle = con.prepareStatement(sqlDetalle);
                    stmtDetalle.setString(1, idPedido);
                    rsDetalle = stmtDetalle.executeQuery();
                    
                    while (rsDetalle.next()) {
                    %>
                    <tr>
                        <td><%= rsDetalle.getString("nombre") %></td>
                        <td><%= rsDetalle.getInt("cantidad") %></td>
                        <td>$<%= String.format("%.2f", rsDetalle.getDouble("precio_unitario")) %></td>
                        <td>$<%= String.format("%.2f", rsDetalle.getDouble("subtotal")) %></td>
                    </tr>
                    <% } %>
                </table>
        <%
            } else {
        %>
                <p class="error">Pedido no encontrado o no tienes permiso para verlo.</p>
        <%
            }
        } catch (Exception e) {
            out.println("<p class='error'>Error al cargar el pedido: " + e.getMessage() + "</p>");
        } finally {
            if (rsDetalle != null) try { rsDetalle.close(); } catch (SQLException e) {}
            if (rsPedido != null) try { rsPedido.close(); } catch (SQLException e) {}
            if (stmtDetalle != null) try { stmtDetalle.close(); } catch (SQLException e) {}
            if (stmtPedido != null) try { stmtPedido.close(); } catch (SQLException e) {}
            if (con != null) try { con.close(); } catch (SQLException e) {}
        }
        %>
        
        <div class="mt-20">
            <a href="ConsultarPedido.jsp"><button>Volver a Mis Pedidos</button></a>
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