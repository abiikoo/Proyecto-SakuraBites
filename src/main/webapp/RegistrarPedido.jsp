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
    <title>Registrar Pedido - Sakura Bites Admin</title>
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

    <section class="section-right-margin">
        <h1>Registrar Pedido Manual</h1>
        <p class="muted">Use esta página para registrar pedidos telefónicos o presenciales</p>
        
        <!-- Información del cliente -->
        <form id="formPedido" action="procesarPedidoAdmin.jsp" method="post">
            <h2>Información del Cliente</h2>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                <div>
                    <label for="nombre_cliente">Nombre del Cliente:</label>
                    <input type="text" id="nombre_cliente" name="nombre_cliente" required>
                </div>
                <div>
                    <label for="telefono">Teléfono:</label>
                    <input type="text" id="telefono" name="telefono" required>
                </div>
            </div>
            
            <label for="direccion">Dirección (para delivery):</label>
            <textarea id="direccion" name="direccion" rows="2"></textarea>
            
            <label for="tipo_pedido">Tipo de Pedido:</label>
            <select id="tipo_pedido" name="tipo_pedido" required>
                <option value="local">Para comer aquí</option>
                <option value="llevar">Para llevar</option>
                <option value="delivery">Delivery</option>
            </select>
            
            <!-- Selección de productos -->
            <h2>Seleccionar Productos</h2>
            
            <!-- Pestañas de categorías -->
            <div class="mb-20">
                <button type="button" onclick="filtrarCategoria('todos')" class="active">Todos</button>
                <button type="button" onclick="filtrarCategoria('entrada')">Entradas</button>
                <button type="button" onclick="filtrarCategoria('plato_principal')">Platos Principales</button>
                <button type="button" onclick="filtrarCategoria('postre')">Postres</button>
                <button type="button" onclick="filtrarCategoria('bebida')">Bebidas</button>
            </div>
            
            <div class="productos-grid">
                <%
                Connection con = null;
                Statement stmt = null;
                ResultSet rs = null;
                
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
                    stmt = con.createStatement();
                    rs = stmt.executeQuery("SELECT * FROM productos WHERE stock > 0 ORDER BY categoria, nombre");
                    
                    while (rs.next()) {
                %>
                <div class="producto-card" data-categoria="<%= rs.getString("categoria") %>">
                    <h4><%= rs.getString("nombre") %></h4>
                    <p class="small-text"><%= rs.getString("descripcion") %></p>
                    <p><strong>$<%= rs.getDouble("precio") %></strong></p>
                    <div class="cantidad-control">
                        <button type="button" onclick="disminuir(<%= rs.getInt("id_producto") %>)">-</button>
                        <input type="number" id="cant_<%= rs.getInt("id_producto") %>" 
                               name="cantidad_<%= rs.getInt("id_producto") %>" 
                               value="0" min="0" max="<%= rs.getInt("stock") %>" 
                               onchange="actualizarTotal()">
                        <button type="button" onclick="aumentar(<%= rs.getInt("id_producto") %>, <%= rs.getInt("stock") %>)">+</button>
                    </div>
                    <input type="hidden" id="precio_<%= rs.getInt("id_producto") %>" value="<%= rs.getDouble("precio") %>">
                    <input type="hidden" id="nombre_<%= rs.getInt("id_producto") %>" value="<%= rs.getString("nombre") %>">
                </div>
                <%
                    }
                } catch (Exception e) {
                    // Mostrar productos de ejemplo si no hay conexión
                %>
                <div class="producto-card" data-categoria="entrada">
                    <h4>Gyoza</h4>
                    <p class="small-text">Dumplings japoneses</p>
                    <p><strong>$5.99</strong></p>
                    <div class="cantidad-control">
                        <button type="button" onclick="disminuir(1)">-</button>
                        <input type="number" id="cant_1" name="cantidad_1" value="0" min="0" max="50" onchange="actualizarTotal()">
                        <button type="button" onclick="aumentar(1, 50)">+</button>
                    </div>
                    <input type="hidden" id="precio_1" value="5.99">
                    <input type="hidden" id="nombre_1" value="Gyoza">
                </div>
                <div class="producto-card" data-categoria="plato_principal">
                    <h4>Ramen</h4>
                    <p class="small-text">Sopa japonesa tradicional</p>
                    <p><strong>$12.99</strong></p>
                    <div class="cantidad-control">
                        <button type="button" onclick="disminuir(2)">-</button>
                        <input type="number" id="cant_2" name="cantidad_2" value="0" min="0" max="30" onchange="actualizarTotal()">
                        <button type="button" onclick="aumentar(2, 30)">+</button>
                    </div>
                    <input type="hidden" id="precio_2" value="12.99">
                    <input type="hidden" id="nombre_2" value="Ramen">
                </div>
                <%
                } finally {
                    if (rs != null) rs.close();
                    if (stmt != null) stmt.close();
                    if (con != null) con.close();
                }
                %>
            </div>
        </form>
    </section>
    
    <!-- Resumen del pedido (fijo a la derecha) -->
    <div class="pedido-resumen" style="position: fixed; right: 20px; top: 200px; width: 300px; max-height: 70vh; overflow-y: auto;">
        <h3>Resumen del Pedido</h3>
        <div id="items-pedido" style="max-height: 250px; overflow-y: auto;">
            <p class="muted">No hay productos seleccionados</p>
        </div>
        <hr>
        <p><strong>Total: $<span id="total">0.00</span></strong></p>
        
        <label for="metodo_pago">Método de Pago:</label>
        <select id="metodo_pago" name="metodo_pago" form="formPedido" required>
            <option value="">Seleccione...</option>
            <option value="efectivo">Efectivo</option>
            <option value="tarjeta">Tarjeta</option>
            <option value="transferencia">Transferencia</option>
        </select>
        
        <label for="notas">Notas:</label>
        <textarea id="notas" name="notas" form="formPedido" rows="3" placeholder="Instrucciones especiales..."></textarea>
        
        <button type="submit" form="formPedido" class="w-100 mt-15">Confirmar Pedido</button>
    </div>

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
        function aumentar(id, maxStock) {
            const input = document.getElementById('cant_' + id);
            if (parseInt(input.value) < maxStock) {
                input.value = parseInt(input.value) + 1;
                actualizarTotal();
            }
        }
        
        function disminuir(id) {
            const input = document.getElementById('cant_' + id);
            if (parseInt(input.value) > 0) {
                input.value = parseInt(input.value) - 1;
                actualizarTotal();
            }
        }
        
        function actualizarTotal() {
            let total = 0;
            let items = '';
            const inputs = document.querySelectorAll('input[type="number"][id^="cant_"]');
            
            inputs.forEach(input => {
                const cantidad = parseInt(input.value);
                if (cantidad > 0) {
                    const id = input.id.replace('cant_', '');
                    const precio = parseFloat(document.getElementById('precio_' + id).value);
                    const nombre = document.getElementById('nombre_' + id).value;
                    const subtotal = cantidad * precio;
                    total += subtotal;
                    items += `<p>${cantidad}x ${nombre} - $${subtotal.toFixed(2)}</p>`;
                }
            });
            
            document.getElementById('total').textContent = total.toFixed(2);
            document.getElementById('items-pedido').innerHTML = items || '<p class="muted">No hay productos seleccionados</p>';
        }
        
        function filtrarCategoria(categoria) {
            const productos = document.querySelectorAll('.producto-card');
            const botones = document.querySelectorAll('button[onclick^="filtrarCategoria"]');
            
            botones.forEach(btn => btn.classList.remove('active'));
            event.target.classList.add('active');
            
            productos.forEach(producto => {
                if (categoria === 'todos' || producto.dataset.categoria === categoria) {
                    producto.style.display = 'block';
                } else {
                    producto.style.display = 'none';
                }
            });
        }
    </script>
</body>
</html>