<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
// Verificar si el usuario está logueado y no es admin
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}
if ("admin".equals(session.getAttribute("tipo_usuario"))) {
    response.sendRedirect("Historial.jsp");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Mis Pedidos - Sakura Bites</title>
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
        <h1>Mis Pedidos</h1>
        
        <!-- Formulario de búsqueda -->
        <form method="get" action="ConsultarPedido.jsp">
            <div class="flex gap-10">
                <div>
                    <label for="buscar">Buscar pedido:</label>
                    <input type="text" id="buscar" name="buscar" placeholder="Número de pedido o teléfono">
                </div>
                <input type="submit" value="Buscar">
            </div>
        </form>
        
        <!-- Lista de pedidos -->
        <h2>Historial de Pedidos</h2>
        <%
        Connection con = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        String clienteId = (String) session.getAttribute("cliente_id");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
            
            String query = "SELECT * FROM pedidos WHERE cliente_id = ? ";
            String buscar = request.getParameter("buscar");
            
            if (buscar != null && !buscar.isEmpty()) {
                query += "AND (id_pedido = ? OR telefono LIKE ?) ";
            }
            query += "ORDER BY fecha DESC";
            
            stmt = con.prepareStatement(query);
            stmt.setString(1, clienteId);
            
            if (buscar != null && !buscar.isEmpty()) {
                stmt.setString(2, buscar);
                stmt.setString(3, "%" + buscar + "%");
            }
            
            rs = stmt.executeQuery();
            
            if (!rs.isBeforeFirst()) {
        %>
                <p>No se encontraron pedidos.</p>
        <% } else { %>
                <table>
                    <tr>
                        <th>Nº Pedido</th>
                        <th>Fecha</th>
                        <th>Estado</th>
                        <th>Total</th>
                        <th>Método de Pago</th>
                        <th>Acciones</th>
                    </tr>
                    <%
                    while (rs.next()) {
                        String estado = rs.getString("estado");
                        String claseEstado = "";
                        if ("completado".equals(estado)) claseEstado = "success";
                        else if ("cancelado".equals(estado)) claseEstado = "error";
                        else if ("en_preparacion".equals(estado)) claseEstado = "warning";
                    %>
                    <tr>
                        <td>#<%= rs.getInt("id_pedido") %></td>
                        <td><%= rs.getTimestamp("fecha") %></td>
                        <td><span class="<%= claseEstado %>"><%= estado %></span></td>
                        <td>$<%= String.format("%.2f", rs.getDouble("total")) %></td>
                        <td><%= rs.getString("metodo_pago") %></td>
                        <td>
                            <a href="detallePedido.jsp?id=<%= rs.getInt("id_pedido") %>">Ver Detalle</a>
                        </td>
                    </tr>
                    <% } %>
                </table>
        <% }
        } catch (Exception e) {
            out.println("<p class='error'>Error al cargar pedidos: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (con != null) try { con.close(); } catch (SQLException e) {}
        }
        %>
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