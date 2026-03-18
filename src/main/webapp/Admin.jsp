<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" %>

<%
// ===== VERIFICAR PERMISOS DE ADMINISTRADOR =====
// Solo los administradores pueden acceder a este panel
if (session.getAttribute("usuario") == null || !"admin".equals(session.getAttribute("tipo_usuario"))) {
    response.sendRedirect("login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Panel Administrativo - Sakura Bites</title>
    <link rel="stylesheet" href="CSS/styles.css">
</head>
<body>
    <!-- ===== ENCABEZADO DE ADMINISTRACIÓN ===== -->
    <header>
        <h1>🌸 Sakura Bites 🌸</h1>
        <nav>
            <img src="Imagenes/LogoSakuraBites.png" alt="Logo Sakura Bites" width="100">
            <!-- Navegación específica para administradores -->
            <a href="Admin.jsp">Panel Admin</a>
            <a href="Inventario.jsp">Inventario</a>
            <a href="Horarios.jsp">Horarios</a>
            <a href="Historial.jsp">Historial de Pedidos</a>
            <a href="RegistrarPedido.jsp">Registrar Pedido</a>
            <a href="https://www.google.com" target="_blank">🔍</a>
        </nav>
    </header>

    <section>
        <h1>Panel de Administración</h1>
        
        <!-- ===== OPCIONES PRINCIPALES DE ADMINISTRACIÓN ===== -->
        <div class="admin-panel">
            <h2>Opciones de Administrador</h2>
            
            <!-- ===== GESTIÓN DE EMPLEADOS ===== -->
            <div>
                <h3>Gestión de Empleados</h3>
                <p>Opciones disponibles:</p>
                <ul>
                    <li>Cocinero</li>
                    <li>Cajero</li>
                    <li>Entregas</li>
                    <li>Admin</li>
                </ul>
                <a href="GestionEmpleados.jsp"><button>Gestionar Empleados</button></a>
            </div>
            
            <!-- ===== ACCESOS RÁPIDOS ===== -->
            <!-- Enlaces directos a las funciones más usadas -->
            <div class="mt-30">
                <h3>Accesos Rápidos</h3>
                <div class="btn-grid">
                    <a href="Inventario.jsp"><button class="w-100">Ver Inventario</button></a>
                    <a href="Historial.jsp"><button class="w-100">Ver Historial de Pedidos</button></a>
                    <a href="Horarios.jsp"><button class="w-100">Lista de Horarios</button></a>
                    <a href="RegistrarPedido.jsp"><button class="w-100">Registrar Pedido Manual</button></a>
                </div>
            </div>
            
            <!-- ===== RESUMEN DEL DÍA ===== -->
            <!-- Estadísticas importantes para el administrador -->
            <div class="mt-30">
                <h3>Resumen del Día</h3>
                <table>
                    <tr>
                        <th>Métrica</th>
                        <th>Valor</th>
                    </tr>
                    <tr>
                        <td>Pedidos realizados</td>
                        <td>45</td>  <!-- En una implementación real, esto vendría de la base de datos -->
                    </tr>
                    <tr>
                        <td>Ingresos totales</td>
                        <td>$1,250.00</td>
                    </tr>
                    <tr>
                        <td>Pedidos pendientes</td>
                        <td>3</td>
                    </tr>
                </table>
            </div>
        </div>
    </section>

    <!-- ===== PIE DE PÁGINA ===== -->
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