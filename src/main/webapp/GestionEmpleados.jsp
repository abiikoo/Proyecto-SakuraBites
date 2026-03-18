<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
// Verificar si el usuario es admin
if (session.getAttribute("usuario") == null || !"admin".equals(session.getAttribute("tipo_usuario"))) {
    response.sendRedirect("login.jsp");
    return;
}

// Procesar formulario si es POST
String mensaje = "";
String tipoMensaje = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String accion = request.getParameter("accion");
    
    Connection con = null;
    PreparedStatement stmt = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
        
        if ("agregar".equals(accion)) {
            String nombre = request.getParameter("nombre");
            String cargo = request.getParameter("cargo");
            String telefono = request.getParameter("telefono");
            String email = request.getParameter("email");
            
            String sql = "INSERT INTO empleados (nombre, cargo, telefono, email, fecha_contratacion) VALUES (?, ?, ?, ?, CURRENT_DATE)";
            stmt = con.prepareStatement(sql);
            stmt.setString(1, nombre);
            stmt.setString(2, cargo);
            stmt.setString(3, telefono);
            stmt.setString(4, email);
            
            int filas = stmt.executeUpdate();
            if (filas > 0) {
                mensaje = "Empleado agregado exitosamente";
                tipoMensaje = "success";
            }
            
        } else if ("activar".equals(accion) || "desactivar".equals(accion)) {
            String idEmpleado = request.getParameter("id_empleado");
            boolean activo = "activar".equals(accion);
            
            String sql = "UPDATE empleados SET activo = ? WHERE id_empleado = ?";
            stmt = con.prepareStatement(sql);
            stmt.setBoolean(1, activo);
            stmt.setString(2, idEmpleado);
            
            int filas = stmt.executeUpdate();
            if (filas > 0) {
                mensaje = "Estado del empleado actualizado";
                tipoMensaje = "success";
            }
        }
        
    } catch (Exception e) {
        mensaje = "Error: " + e.getMessage();
        tipoMensaje = "error";
    } finally {
        if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Empleados - Sakura Bites Admin</title>
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
            <a href="GestionEmpleados.jsp">Empleados</a>
            <a href="https://www.google.com" target="_blank">🔍</a>
        </nav>
    </header>

    <section>
        <h1>Gestión de Empleados</h1>
        
        <% if (!mensaje.isEmpty()) { %>
            <div class="<%= tipoMensaje %>"><%= mensaje %></div>
        <% } %>
        
        <!-- Formulario para agregar empleado -->
        <div class="admin-panel mb-20">
            <h2>Agregar Nuevo Empleado</h2>
            <form method="post" action="GestionEmpleados.jsp">
                <input type="hidden" name="accion" value="agregar">
                
                <div class="grid-2 gap-10">
                    <div>
                        <label for="nombre">Nombre Completo:</label>
                        <input type="text" id="nombre" name="nombre" required>
                    </div>
                    <div>
                        <label for="cargo">Cargo:</label>
                        <select id="cargo" name="cargo" required>
                            <option value="">Seleccione...</option>
                            <option value="cocinero">Cocinero</option>
                            <option value="cajero">Cajero</option>
                            <option value="entregas">Entregas</option>
                            <option value="admin">Administrador</option>
                        </select>
                    </div>
                    <div>
                        <label for="telefono">Teléfono:</label>
                        <input type="text" id="telefono" name="telefono" required>
                    </div>
                    <div>
                        <label for="email">Email:</label>
                        <input type="email" id="email" name="email" required>
                    </div>
                </div>
                
                <input type="submit" value="Agregar Empleado">
            </form>
        </div>
        
        <!-- Lista de empleados -->
        <h2>Empleados Actuales</h2>
        <table>
            <tr>
                <th>ID</th>
                <th>Nombre</th>
                <th>Cargo</th>
                <th>Teléfono</th>
                <th>Email</th>
                <th>Fecha Contratación</th>
                <th>Horas/Semana</th>
                <th>Estado</th>
                <th>Acciones</th>
            </tr>
            <%
            Connection con = null;
            Statement stmt = null;
            ResultSet rs = null;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
                stmt = con.createStatement();
                rs = stmt.executeQuery("SELECT * FROM empleados ORDER BY cargo, nombre");
                
                while (rs.next()) {
                    boolean activo = rs.getBoolean("activo");
                    String claseEstado = activo ? "success" : "error";
                    String textoEstado = activo ? "Activo" : "Inactivo";
            %>
            <tr>
                <td><%= rs.getInt("id_empleado") %></td>
                <td><%= rs.getString("nombre") %></td>
                <td><%= rs.getString("cargo") %></td>
                <td><%= rs.getString("telefono") %></td>
                <td><%= rs.getString("email") %></td>
                <td><%= rs.getDate("fecha_contratacion") %></td>
                <td><%= rs.getInt("horas_semanales") %></td>
                <td><span class="<%= claseEstado %>"><%= textoEstado %></span></td>
                <td>
                    <a href="editarEmpleado.jsp?id=<%= rs.getInt("id_empleado") %>">Editar</a> |
                    <form method="post" action="GestionEmpleados.jsp" class="inline">
                        <input type="hidden" name="accion" value="<%= activo ? "desactivar" : "activar" %>">
                        <input type="hidden" name="id_empleado" value="<%= rs.getInt("id_empleado") %>">
                        <input type="submit" value="<%= activo ? "Desactivar" : "Activar" %>" 
                               onclick="return confirm('¿Está seguro de <%= activo ? "desactivar" : "activar" %> este empleado?')">
                    </form>
                </td>
            </tr>
            <%
                }
            } catch (Exception e) {
                out.println("<tr><td colspan='9' class='error'>Error al cargar empleados: " + e.getMessage() + "</td></tr>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
                if (con != null) try { con.close(); } catch (SQLException e) {}
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
</body>
</html>