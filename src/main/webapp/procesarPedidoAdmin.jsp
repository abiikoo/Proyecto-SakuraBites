<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
// Verificar que el usuario sea admin
if (session.getAttribute("usuario") == null || !"admin".equals(session.getAttribute("tipo_usuario"))) {
    response.sendRedirect("login.jsp");
    return;
}

// Obtener datos del formulario
String nombreCliente = request.getParameter("nombre_cliente");
String telefono = request.getParameter("telefono");
String tipoUsuario = request.getParameter("tipo_usuario");
String direccion = request.getParameter("direccion");
String metodoPago = request.getParameter("metodo_pago");
String notas = request.getParameter("notas");

Connection con = null;
PreparedStatement stmtCliente = null;
PreparedStatement stmtPedido = null;
PreparedStatement stmtDetalle = null;
ResultSet rs = null;
boolean exito = false;
int idPedido = 0;
double total = 0;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
    con.setAutoCommit(false);
    
    // 1. Buscar o crear cliente
    int clienteId = 0;
    String sqlBuscarCliente = "SELECT id_cliente FROM clientes WHERE telefono = ?";
    stmtCliente = con.prepareStatement(sqlBuscarCliente);
    stmtCliente.setString(1, telefono);
    rs = stmtCliente.executeQuery();
    
    if (rs.next()) {
        clienteId = rs.getInt("id_cliente");
    } else {
        // Crear cliente temporal si no existe
        String sqlCrearCliente = "INSERT INTO clientes (nombre, telefono) VALUES (?, ?)";
        stmtCliente = con.prepareStatement(sqlCrearCliente, Statement.RETURN_GENERATED_KEYS);
        stmtCliente.setString(1, nombreCliente);
        stmtCliente.setString(2, telefono);
        stmtCliente.executeUpdate();
        
        rs = stmtCliente.getGeneratedKeys();
        if (rs.next()) {
            clienteId = rs.getInt(1);
        }
    }
    
    // 2. Crear pedido
    String sqlPedido = "INSERT INTO pedidos (cliente_id, total, estado, metodo_pago, tipo_pedido, direccion_entrega, telefono, notas) " +
                       "VALUES (?, 0, 'pendiente', ?, 'llevar', ?, ?, ?)";
    stmtPedido = con.prepareStatement(sqlPedido, Statement.RETURN_GENERATED_KEYS);
    stmtPedido.setInt(1, clienteId);
    stmtPedido.setString(2, metodoPago);
    stmtPedido.setString(3, direccion);
    stmtPedido.setString(4, telefono);
    stmtPedido.setString(5, notas);
    stmtPedido.executeUpdate();
    
    rs = stmtPedido.getGeneratedKeys();
    if (rs.next()) {
        idPedido = rs.getInt(1);
    }
    
    // 3. Agregar productos del formulario
    String sqlDetalle = "INSERT INTO detalle_pedidos (id_pedido, id_producto, cantidad, precio_unitario, subtotal) VALUES (?, ?, ?, ?, ?)";
    stmtDetalle = con.prepareStatement(sqlDetalle);
    
    // Procesar productos seleccionados
    for (int i = 1; i <= 100; i++) { // Asumiendo máximo 100 productos
        String cantidadStr = request.getParameter("cantidad_" + i);
        if (cantidadStr != null && !"0".equals(cantidadStr)) {
            int cantidad = Integer.parseInt(cantidadStr);
            
            // Obtener precio del producto
            PreparedStatement stmtPrecio = con.prepareStatement("SELECT precio FROM productos WHERE id_producto = ?");
            stmtPrecio.setInt(1, i);
            ResultSet rsPrecio = stmtPrecio.executeQuery();
            
            if (rsPrecio.next()) {
                double precio = rsPrecio.getDouble("precio");
                double subtotal = precio * cantidad;
                total += subtotal;
                
                stmtDetalle.setInt(1, idPedido);
                stmtDetalle.setInt(2, i);
                stmtDetalle.setInt(3, cantidad);
                stmtDetalle.setDouble(4, precio);
                stmtDetalle.setDouble(5, subtotal);
                stmtDetalle.executeUpdate();
            }
            rsPrecio.close();
            stmtPrecio.close();
        }
    }
    
    // 4. Actualizar total del pedido
    PreparedStatement stmtActualizar = con.prepareStatement("UPDATE pedidos SET total = ? WHERE id_pedido = ?");
    stmtActualizar.setDouble(1, total);
    stmtActualizar.setInt(2, idPedido);
    stmtActualizar.executeUpdate();
    stmtActualizar.close();
    
    con.commit();
    exito = true;
    
} catch (Exception e) {
    if (con != null) {
        try {
            con.rollback();
        } catch (SQLException ex) {}
    }
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (stmtDetalle != null) try { stmtDetalle.close(); } catch (SQLException e) {}
    if (stmtPedido != null) try { stmtPedido.close(); } catch (SQLException e) {}
    if (stmtCliente != null) try { stmtCliente.close(); } catch (SQLException e) {}
    if (con != null) try { con.close(); } catch (SQLException e) {}
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Procesando Pedido - Sakura Bites Admin</title>
    <link rel="stylesheet" href="CSS/styles.css">
    <% if (exito) { %>
        <meta http-equiv="refresh" content="3;url=Historial.jsp">
    <% } %>
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

    <section class="text-center">
        <% if (exito) { %>
            <div class="success">
                <h1>✓ ¡Pedido Registrado!</h1>
                <p>Pedido #<%= idPedido %> creado exitosamente</p>
                <p>Cliente: <%= nombreCliente %></p>
                <p>Total: $<%= String.format("%.2f", total) %></p>
                <p class="small-text">Redirigiendo al historial...</p>
            </div>
        <% } else { %>
            <div class="error">
                <h1>✗ Error al procesar pedido</h1>
                <p>Hubo un problema al registrar el pedido.</p>
            </div>
        <% } %>
        
        <div class="mt-20">
            <a href="Historial.jsp"><button>Ver Historial</button></a>
            <a href="RegistrarPedido.jsp"><button>Nuevo Pedido</button></a>
        </div>
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