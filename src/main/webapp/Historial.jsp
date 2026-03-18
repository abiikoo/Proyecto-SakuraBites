<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
// Verificar si el usuario es admin
if (session.getAttribute("usuario") == null || !"admin".equals(session.getAttribute("tipo_usuario"))) {
    response.sendRedirect("login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Historial de Pedidos - Sakura Bites Admin</title>
    <link rel="stylesheet" href="CSS/styles.css">
</head>
<body>
    <header>
    <h1>🌸 Sakura Bites 🌸</h1>
        <nav>
        <img src="Imagenes/LogoSakuraBites.png" alt="Logo Sakura Bites" width="100">
            <a href="Admin.jsp">Panel Admin</a>
            <a href="Inventario.jsp">Inventario</a>
            <a href="Horarios.jsp">Horarios</a>
            <a href="Historial.jsp">Historial de Pedidos</a>
            <a href="RegistrarPedido.jsp">Registrar Pedido</a>
            <a href="https://www.google.com" target="_blank">🔍</a>
        </nav>
    </header>

    <section>
        <h1>Historial de Pedidos</h1>
        
        <!-- Filtros -->
        <form method="get" action="Historial.jsp">
            <div class="flex gap-10 mb-20">
                <div>
                    <label for="fecha_inicio">Desde:</label>
                    <input type="date" id="fecha_inicio" name="fecha_inicio" value="<%= request.getParameter("fecha_inicio") %>">
                </div>
                <div>
                    <label for="fecha_fin">Hasta:</label>
                    <input type="date" id="fecha_fin" name="fecha_fin" value="<%= request.getParameter("fecha_fin") %>">
                </div>
                <div>
                    <label for="estado">Estado:</label>
                    <select id="estado" name="estado">
                        <option value="">Todos</option>
                        <option value="pendiente" <%= "pendiente".equals(request.getParameter("estado")) ? "selected" : "" %>>Pendiente</option>
                        <option value="en_preparacion" <%= "en_preparacion".equals(request.getParameter("estado")) ? "selected" : "" %>>En Preparación</option>
                        <option value="completado" <%= "completado".equals(request.getParameter("estado")) ? "selected" : "" %>>Completado</option>
                        <option value="cancelado" <%= "cancelado".equals(request.getParameter("estado")) ? "selected" : "" %>>Cancelado</option>
                    </select>
                </div>
                <input type="submit" value="Filtrar">
            </div>
        </form>
        
        <!-- Opción de ordenar -->
        <div class="mb-20">
            <label>Ordenar por:</label>
            <select onchange="ordenarTabla(this.value)">
                <option value="fecha_desc">Fecha (más reciente)</option>
                <option value="fecha_asc">Fecha (más antiguo)</option>
                <option value="total_desc">Total (mayor a menor)</option>
                <option value="total_asc">Total (menor a mayor)</option>
            </select>
        </div>
        
        <!-- Lista de pedidos -->
        <table>
            <tr>
                <th>Nº Pedido</th>
                <th>Fecha/Hora</th>
                <th>Cliente</th>
                <th>Teléfono</th>
                <th>Total</th>
                <th>Estado</th>
                <th>Método Pago</th>
                <th>Acciones</th>
            </tr>
            <%
            Connection con = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;
            
            try {
                Class.forName("com.mysql.jdbc.Driver");
                con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
                
                String query = "SELECT p.*, c.nombre as cliente_nombre, c.telefono " +
                              "FROM pedidos p " +
                              "JOIN clientes c ON p.cliente_id = c.id_cliente " +
                              "WHERE 1=1 ";
                
                // Aplicar filtros
                if (request.getParameter("fecha_inicio") != null && !request.getParameter("fecha_inicio").isEmpty()) {
                    query += " AND DATE(p.fecha) >= ?";
                }
                if (request.getParameter("fecha_fin") != null && !request.getParameter("fecha_fin").isEmpty()) {
                    query += " AND DATE(p.fecha) <= ?";
                }
                if (request.getParameter("estado") != null && !request.getParameter("estado").isEmpty()) {
                    query += " AND p.estado = ?";
                }
                
                query += " ORDER BY p.fecha DESC";
                
                stmt = con.prepareStatement(query);
                
                // Configurar parámetros
                int paramIndex = 1;
                if (request.getParameter("fecha_inicio") != null && !request.getParameter("fecha_inicio").isEmpty()) {
                    stmt.setString(paramIndex++, request.getParameter("fecha_inicio"));
                }
                if (request.getParameter("fecha_fin") != null && !request.getParameter("fecha_fin").isEmpty()) {
                    stmt.setString(paramIndex++, request.getParameter("fecha_fin"));
                }
                if (request.getParameter("estado") != null && !request.getParameter("estado").isEmpty()) {
                    stmt.setString(paramIndex++, request.getParameter("estado"));
                }
                
                rs = stmt.executeQuery();
                
                double totalVentas = 0;
                int totalPedidos = 0;
                
                while (rs.next()) {
                    totalPedidos++;
                    totalVentas += rs.getDouble("total");
                    String estado = rs.getString("estado");
                    String claseEstado = "";
                    if ("completado".equals(estado)) claseEstado = "success";
                    else if ("cancelado".equals(estado)) claseEstado = "error";
                    else if ("en_preparacion".equals(estado)) claseEstado = "warning";
            %>
            <tr>
                <td>#<%= rs.getInt("id_pedido") %></td>
                <td><%= rs.getTimestamp("fecha") %></td>
                <td><%= rs.getString("cliente_nombre") %></td>
                <td><%= rs.getString("telefono") %></td>
                <td>$<%= String.format("%.2f", rs.getDouble("total")) %></td>
                <td><span class="<%= claseEstado %>"><%= estado %></span></td>
                <td><%= rs.getString("metodo_pago") %></td>
                <td>
                    <a href="detallePedidoAdmin.jsp?id=<%= rs.getInt("id_pedido") %>">Ver Detalle</a>
                </td>
            </tr>
            <%
                }
            %>
            <!-- Fila de totales -->
            <tr class="row-totales">
                <td colspan="4">TOTALES</td>
                <td>$<%= String.format("%.2f", totalVentas) %></td>
                <td colspan="3">Total pedidos: <%= totalPedidos %></td>
            </tr>
            <%
            } catch (Exception e) {
                out.println("<p class='error'>Error al cargar historial: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            }
            %>
        </table>
    </section>

    <footer>
        <nav>
            <a href="Admin.jsp">Panel Admin</a> |
            <a href="Inventario.jsp">Inventario</a> |
            <a href="Horarios.jsp">Horarios</a> |
            <a href="Logout.jsp">Logout</a>
        </nav>
        <p>&copy; 2025 Sakura Bites. Todos los derechos reservados.</p>
    </footer>

    <script>
        function ordenarTabla(criterio) {
            // Implementar ordenamiento con JavaScript o recargar página con parámetro
            window.location.href = 'Historial.jsp?orden=' + criterio;
        }
    </script>
</body>
</html>