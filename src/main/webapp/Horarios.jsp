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
    <title>Horarios - Sakura Bites Admin</title>
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
        <h1>Gestión de Horarios</h1>
        
        <!-- Vista semanal -->
        <h2>Vista Semanal</h2>
        <div class="calendario">
            <div class="dia-header">Lunes</div>
            <div class="dia-header">Martes</div>
            <div class="dia-header">Miércoles</div>
            <div class="dia-header">Jueves</div>
            <div class="dia-header">Viernes</div>
            <div class="dia-header">Sábado</div>
            <div class="dia-header">Domingo</div>
            
            <div class="dia">
                <strong>11:00 AM - 7:00 PM</strong><br>
                Cocinero: Juan<br>
                Cajero: María
            </div>
            <div class="dia">
                <strong>11:00 AM - 7:00 PM</strong><br>
                Cocinero: Pedro<br>
                Cajero: Ana
            </div>
            <div class="dia">
                <strong>11:00 AM - 7:00 PM</strong><br>
                Cocinero: Juan<br>
                Cajero: María
            </div>
            <div class="dia">
                <strong>11:00 AM - 7:00 PM</strong><br>
                Cocinero: Pedro<br>
                Cajero: Ana
            </div>
            <div class="dia">
                <strong>11:00 AM - 9:00 PM</strong><br>
                Cocinero: Juan<br>
                Cajero: María<br>
                Extra: Luis
            </div>
            <div class="dia">
                <strong>12:00 PM - 10:00 PM</strong><br>
                Cocinero: Pedro<br>
                Cajero: Ana<br>
                Extra: Carlos
            </div>
            <div class="dia">
                <strong>12:00 PM - 8:00 PM</strong><br>
                Cocinero: Juan<br>
                Cajero: María
            </div>
        </div>
        
        <!-- Lista de empleados -->
        <h2>Lista de Empleados</h2>
        <table>
            <tr>
                <th>ID</th>
                <th>Nombre</th>
                <th>Cargo</th>
                <th>Teléfono</th>
                <th>Email</th>
                <th>Horas Semanales</th>
            </tr>
            <%
            Connection con = null;
            Statement stmt = null;
            ResultSet rs = null;
            
            try {
                Class.forName("com.mysql.jdbc.Driver");
                con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
                stmt = con.createStatement();
                rs = stmt.executeQuery("SELECT * FROM empleados ORDER BY cargo, nombre");
                
                while (rs.next()) {
            %>
            <tr>
                <td><%= rs.getInt("id_empleado") %></td>
                <td><%= rs.getString("nombre") %></td>
                <td><%= rs.getString("cargo") %></td>
                <td><%= rs.getString("telefono") %></td>
                <td><%= rs.getString("email") %></td>
                <td><%= rs.getInt("horas_semanales") %></td>
            </tr>
            <%
                }
            } catch (Exception e) {
                // Si no hay conexión a BD, mostrar datos de ejemplo
            %>
            <tr>
                <td>1</td>
                <td>Juan Pérez</td>
                <td>Cocinero</td>
                <td>6123-4567</td>
                <td>juan@sakurabites.com</td>
                <td>40</td>
                <td><button>Editar Horario</button></td>
            </tr>
            <tr>
                <td>2</td>
                <td>María González</td>
                <td>Cajero</td>
                <td>6987-6543</td>
                <td>maria@sakurabites.com</td>
                <td>40</td>
                <td><button>Editar Horario</button></td>
            </tr>
            <tr>
                <td>3</td>
                <td>Pedro López</td>
                <td>Cocinero</td>
                <td>6555-1234</td>
                <td>pedro@sakurabites.com</td>
                <td>32</td>
                <td><button>Editar Horario</button></td>
            </tr>
            <tr>
                <td>4</td>
                <td>Ana Martínez</td>
                <td>Cajero</td>
                <td>6777-9999</td>
                <td>ana@sakurabites.com</td>
                <td>32</td>
                <td><button>Editar Horario</button></td>
            </tr>
            <%
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
</body>
</html>