<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
// ===== CONTROL DE ACCESO =====
// Solo los clientes logueados pueden hacer checkout
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");  // Si no está logueado, va al login
    return;
}
if ("admin".equals(session.getAttribute("tipo_usuario"))) {
    response.sendRedirect("Admin.jsp");  // Si es admin, va al panel admin
    return;
}

// ===== OBTENER INFORMACIÓN DEL USUARIO =====
String idUsuario = (String) session.getAttribute("usuario_id");
String nombreUsuario = (String) session.getAttribute("nombre_usuario");
String correoUsuario = (String) session.getAttribute("usuario");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Checkout - Sakura Bites</title>
    <link rel="stylesheet" href="CSS/styles.css">
</head>
<body>
    <!-- ===== ENCABEZADO PARA CLIENTES ===== -->
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
        <h1>Finalizar Pedido</h1>
        
        <!-- ===== RESUMEN DEL PEDIDO ===== -->
        <!-- Aquí el cliente ve exactamente qué va a comprar y cuánto va a pagar -->
        <div class="admin-panel mb-20">
            <h2>Resumen del Pedido</h2>
            <table>
                <tr>
                    <th>Producto</th>
                    <th>Cantidad</th>
                    <th>Precio</th>
                    <th>Subtotal</th>
                </tr>
                <%
                // ===== OBTENER PRODUCTOS DEL CARRITO =====
                Connection con = null;
                PreparedStatement stmt = null;
                ResultSet rs = null;
                double total = 0;               // Total a pagar
                boolean hayProductos = false;   // ¿Hay algo en el carrito?
                
                try {
                    // Conectar a la base de datos
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
                    
                    // ===== CONSULTA PARA OBTENER EL CARRITO =====
                    // Unimos carrito con productos para obtener nombre y precio actual
                    String sql = "SELECT c.*, p.nombre, p.precio FROM carrito c " +
                                "JOIN productos p ON c.id_producto = p.id_producto " +
                                "WHERE c.id_usuario = ?";
                    stmt = con.prepareStatement(sql);
                    stmt.setString(1, idUsuario);  // Solo los productos de este usuario
                    rs = stmt.executeQuery();
                    
                    // ===== MOSTRAR CADA PRODUCTO DEL CARRITO =====
                    while (rs.next()) {
                        hayProductos = true;  // Confirmamos que hay productos
                        
                        int cantidad = rs.getInt("cantidad");
                        double precio = rs.getDouble("precio");
                        double subtotal = precio * cantidad;  // Precio por cantidad
                        total += subtotal;  // Sumamos al total general
                %>
                <tr>
                    <td><%= rs.getString("nombre") %></td>
                    <td><%= cantidad %></td>
                    <td>$<%= String.format("%.2f", precio) %></td>
                    <td>$<%= String.format("%.2f", subtotal) %></td>
                </tr>
                <% } %>
                <!-- Fila del total final -->
                <tr>
                    <td colspan="3"><strong>Total:</strong></td>
                    <td><strong>$<%= String.format("%.2f", total) %></strong></td>
                </tr>
            </table>
        </div>
        
        <%
        // ===== VERIFICAR QUE HAYA PRODUCTOS =====
        // Si el carrito está vacío, redirigimos al carrito
        if (!hayProductos) {
            response.sendRedirect("Carrito.jsp");
            return;
        }
        %>
        
        <!-- ===== FORMULARIO DE INFORMACIÓN DE ENTREGA ===== -->
        <form action="ProcesarPedido.jsp" method="post">
            <h2>Información de Entrega</h2>
            
            <!-- Información personal del cliente -->
            <div class="grid-2 gap-10">
                <div>
                    <label for="nombre_cliente">Nombre Completo:</label>
                    <!-- Pre-llenar con el nombre del usuario si está disponible -->
                    <input type="text" id="nombre_cliente" name="nombre_cliente" 
                           value="<%= nombreUsuario != null ? nombreUsuario : "" %>" required>
                </div>
                <div>
                    <label for="telefono">Teléfono:</label>
                    <input type="text" id="telefono" name="telefono" required>
                </div>
            </div>
            
            <!-- ===== TIPO DE PEDIDO ===== -->
            <!-- Determina si es para comer aquí, llevar o delivery -->
            <label for="tipo_pedido">Tipo de Pedido:</label>
            <select id="tipo_pedido" name="tipo_pedido" onchange="mostrarDireccion()" required>
                <option value="local">Para comer aquí</option>
                <option value="llevar">Para llevar</option>
                <option value="delivery">Delivery</option>
            </select>
            
            <!-- ===== DIRECCIÓN (SOLO PARA DELIVERY) ===== -->
            <!-- Este campo solo aparece si seleccionan delivery -->
            <div id="direccionDiv" style="display: none;">
                <label for="direccion">Dirección de Entrega:</label>
                <textarea id="direccion" name="direccion" rows="3"></textarea>
            </div>
            
            <!-- ===== MÉTODO DE PAGO ===== -->
            <label for="metodo_pago">Método de Pago:</label>
            <select id="metodo_pago" name="metodo_pago" required>
                <option value="">Seleccione...</option>
                <option value="efectivo">Efectivo</option>
                <option value="tarjeta">Tarjeta</option>
                <option value="transferencia">Transferencia</option>
            </select>
            
            <!-- ===== NOTAS ADICIONALES ===== -->
            <label for="notas">Notas Adicionales:</label>
            <textarea id="notas" name="notas" rows="3" 
                      placeholder="Instrucciones especiales para su pedido..."></textarea>
            
            <!-- Campo oculto con el total (para verificación en el siguiente paso) -->
            <input type="hidden" name="total" value="<%= total %>">
            
            <!-- ===== BOTONES DE ACCIÓN ===== -->
            <div class="mt-20">
                <a href="Carrito.jsp"><button type="button">Volver al Carrito</button></a>
                <input type="submit" value="Confirmar Pedido">
            </div>
        </form>
        
        <%
        } catch (Exception e) {
            // Si hay error al cargar el carrito, mostrar mensaje
            out.println("<p class='error'>Error: " + e.getMessage() + "</p>");
        } finally {
            // ===== LIMPIEZA DE CONEXIONES =====
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (con != null) try { con.close(); } catch (SQLException e) {}
        }
        %>
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
    
    <!-- ===== JAVASCRIPT PARA INTERACTIVIDAD ===== -->
    <script>
        // ===== MOSTRAR U OCULTAR DIRECCIÓN SEGÚN TIPO DE PEDIDO =====
        function mostrarDireccion() {
            var tipo = document.getElementById("tipo_pedido").value;
            var direccionDiv = document.getElementById("direccionDiv");
            var direccionField = document.getElementById("direccion");
            
            if (tipo === "delivery") {
                // Si es delivery, mostrar el campo de dirección y hacerlo obligatorio
                direccionDiv.style.display = "block";
                direccionField.required = true;
            } else {
                // Si no es delivery, ocultar el campo y no es obligatorio
                direccionDiv.style.display = "none";
                direccionField.required = false;
            }
        }
    </script>
</body>
</html>