<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
// Verificar que el usuario esté logueado
if (session.getAttribute("usuario") == null || !"cliente".equals(session.getAttribute("tipo_usuario"))) {
    response.sendRedirect("login.jsp");
    return;
}

String idUsuario = (String) session.getAttribute("usuario_id");
String clienteId = (String) session.getAttribute("cliente_id");

// Obtener datos del formulario
String nombreCliente = request.getParameter("nombre_cliente");
String telefono = request.getParameter("telefono");
String direccion = request.getParameter("direccion");
String metodoPago = request.getParameter("metodo_pago");
String notas = request.getParameter("notas");
String tipoPedido = request.getParameter("tipo_pedido");
String totalStr = request.getParameter("total");
double total = Double.parseDouble(totalStr);

Connection con = null;
PreparedStatement stmtPedido = null;
PreparedStatement stmtDetalle = null;
PreparedStatement stmtCarrito = null;
PreparedStatement stmtLimpiar = null;
ResultSet rs = null;
boolean exito = false;
int idPedido = 0;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
    con.setAutoCommit(false);
    
    // 1. Insertar pedido
    String sqlPedido = "INSERT INTO pedidos (cliente_id, total, estado, metodo_pago, tipo_pedido, direccion_entrega, telefono, notas) " +
                       "VALUES (?, ?, 'pendiente', ?, ?, ?, ?, ?)";
    stmtPedido = con.prepareStatement(sqlPedido, Statement.RETURN_GENERATED_KEYS);
    stmtPedido.setString(1, clienteId);
    stmtPedido.setDouble(2, total);
    stmtPedido.setString(3, metodoPago);
    stmtPedido.setString(4, tipoPedido != null ? tipoPedido : "llevar");
    stmtPedido.setString(5, direccion);
    stmtPedido.setString(6, telefono);
    stmtPedido.setString(7, notas);
    
    stmtPedido.executeUpdate();
    
    // Obtener ID del pedido generado
    rs = stmtPedido.getGeneratedKeys();
    if (rs.next()) {
        idPedido = rs.getInt(1);
    }
    
    // 2. Obtener items del carrito
    String sqlCarrito = "SELECT c.*, p.precio, p.nombre FROM carrito c " +
                        "JOIN productos p ON c.id_producto = p.id_producto " +
                        "WHERE c.id_usuario = ?";
    stmtCarrito = con.prepareStatement(sqlCarrito);
    stmtCarrito.setString(1, idUsuario);
    ResultSet rsCarrito = stmtCarrito.executeQuery();
    
    // 3. Insertar detalles del pedido
    String sqlDetalle = "INSERT INTO detalle_pedidos (id_pedido, id_producto, cantidad, precio_unitario, subtotal) " +
                        "VALUES (?, ?, ?, ?, ?)";
    stmtDetalle = con.prepareStatement(sqlDetalle);
    
    while (rsCarrito.next()) {
        int idProducto = rsCarrito.getInt("id_producto");
        int cantidad = rsCarrito.getInt("cantidad");
        double precio = rsCarrito.getDouble("precio");
        double subtotal = precio * cantidad;
        
        stmtDetalle.setInt(1, idPedido);
        stmtDetalle.setInt(2, idProducto);
        stmtDetalle.setInt(3, cantidad);
        stmtDetalle.setDouble(4, precio);
        stmtDetalle.setDouble(5, subtotal);
        stmtDetalle.executeUpdate();
        
        // Actualizar stock del producto
        String sqlStock = "UPDATE productos SET stock = stock - ? WHERE id_producto = ?";
        PreparedStatement stmtStock = con.prepareStatement(sqlStock);
        stmtStock.setInt(1, cantidad);
        stmtStock.setInt(2, idProducto);
        stmtStock.executeUpdate();
        stmtStock.close();
    }
    
    // 4. Limpiar carrito
    String sqlLimpiar = "DELETE FROM carrito WHERE id_usuario = ?";
    stmtLimpiar = con.prepareStatement(sqlLimpiar);
    stmtLimpiar.setString(1, idUsuario);
    stmtLimpiar.executeUpdate();
    
    // Confirmar transacción
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
    if (stmtCarrito != null) try { stmtCarrito.close(); } catch (SQLException e) {}
    if (stmtPedido != null) try { stmtPedido.close(); } catch (SQLException e) {}
    if (stmtLimpiar != null) try { stmtLimpiar.close(); } catch (SQLException e) {}
    if (con != null) try { con.close(); } catch (SQLException e) {}
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Procesando Pedido - Sakura Bites</title>
    <link rel="stylesheet" href="CSS/styles.css">
    <% if (exito) { %>
        <meta http-equiv="refresh" content="3;url=ConsultarPedido.jsp">
    <% } %>
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

    <section class="text-center">
        <% if (exito) { %>
            <div class="success">
                <h1>✓ ¡Pedido Confirmado!</h1>
                <p>Tu pedido #<%= idPedido %> ha sido recibido exitosamente.</p>
                <p>Total: $<%= String.format("%.2f", total) %></p>
                <p>Te notificaremos cuando esté listo.</p>
                <p class="small-text">Redirigiendo a tus pedidos...</p>
            </div>
        <% } else { %>
            <div class="error">
                <h1>✗ Error al procesar pedido</h1>
                <p>Hubo un problema al procesar tu pedido. Por favor intenta nuevamente.</p>
            </div>
        <% } %>
        
        <div class="mt-20">
            <a href="ConsultarPedido.jsp"><button>Ver Mis Pedidos</button></a>
            <a href="Menu.jsp"><button>Volver al Menú</button></a>
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