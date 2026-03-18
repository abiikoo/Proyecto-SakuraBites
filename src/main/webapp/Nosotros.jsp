<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sobre Nosotros - Sakura Bites</title>
    <link rel="stylesheet" href="CSS/styles.css">
</head>
<body>
    <header>
    <h1>🌸 Sakura Bites 🌸</h1>
        <nav>
        <img src="Imagenes/LogoSakuraBites.png" alt="Logo Sakura Bites" width="100">
            <a href="home.jsp">Inicio</a>
            <a href="Nosotros.jsp">Sobre Nosotros</a>
            <a href="Menu.jsp">Menú</a>
            <a href="login.jsp">Login</a>
            <a href="Registro.jsp">Registro</a>
            <a href="https://www.google.com" target="_blank">🔍</a>
        </nav>
    </header>

    <section>
        <h1>Sobre Nosotros</h1>
        <p>Conoce al equipo detrás de Sakura Bites, comprometidos con traerte la mejor experiencia gastronómica asiática.</p>
        
        <!-- Miembro del equipo 1 -->
        <div class="team-member">
            <img src="Imagenes/Jose 2.0.jpg" alt="flopero" class="member-photo">
            <div class="member-info">
                <h3>José Bustamante</h3>
                <p><strong>Cédula:</strong> 8-1011-1717</p>
                <p><strong>Carrera:</strong> Ingeniería de Software</p>
                <p><strong>Experiencia como desarrollador:</strong> José Bustamante, a lo largo de su carrera de Ingeniería de Software pudo trabajar con distintos lenguajes de programación como HTML, Pseudocódigo, C++, Java, Python, Creación y modificaciones de Bases de datos, etc. Y estos conocimientos los pudo aplicar tanto en proyectos académicos como personales y en un futuro, profesionales. </p>
            </div>
        </div>
        
        <!-- Miembro del equipo 2 -->
        <div class="team-member">
            <img src="Imagenes/danna.jpg" alt="anemicsociety" class="member-photo">
            <div class="member-info">
                <h3>Danna Dawkins</h3>
                <p><strong>Cédula:</strong> 8-1010-1542</p>
                <p><strong>Carrera:</strong> Ingeniería de Software</p>
                <p><strong>Experiencia como desarrollador:</strong> Danna Dawkins, como estudiante de Ingeniería de Software en la Universidad Tecnológica de Panamá, ha desarrollado habilidades en programación orientada a objetos, desarrollo web y de escritorio, bases de datos y arquitectura de computadoras, participando en proyectos como un sistema de registro académico en JSP y una app de escritorio en Java para la gestión de voluntariados. Realizó una pasantía en la vicepresidencia de Transformación Digital del Canal de Panamá, donde colaboró en proyectos de automatización y soluciones ágiles. Además, participé en la Hackathon Linux 2024 como parte del equipo “Hackstreet Boys”, contribuyendo al desarrollo de una solución en entorno Linux bajo presión y en equipo.</p>
            </div>
        </div>
        
        <!-- Miembro del equipo 3 -->
        <div class="team-member">
            <img src="Imagenes/luz.jpg" alt="foquito" class="member-photo">
            <div class="member-info">
                <h3>Luz De León</h3>
                <p><strong>Cédula:</strong> 8-1020-247</p>
                <p><strong>Carrera:</strong> Ingeniería de Software</p>
                <p><strong>Experiencia como desarrollador:</strong> Luz de León es desarrolladora web en Coderland, enfocada en el desarrollo de aplicaciones internas con tecnologías modernas para la web. Tiene experiencia en seguridad de la información gracias a una pasantía en una firma de abogados, y mantiene un fuerte interés en la ciberseguridad. Participó en una hackatón de Linux en 2024 y continúa involucrándose en eventos tecnológicos que promueven el aprendizaje práctico, la innovación y el crecimiento profesional en el ámbito del software.</p>
            </div>
        </div>
        
        <!-- Miembro del equipo 4 -->
        <div class="team-member">
            <img src="Imagenes/abi.jpg" alt="jaasiel" class="member-photo">
            <div class="member-info">
                <h3>Abigail Koo</h3>
                <p><strong>Cédula:</strong> 8-997-974</p>
                <p><strong>Carrera:</strong> Ingeniería de Software</p>
                <p><strong>Experiencia como desarrollador:</strong> Abigail, a lo largo de su formación como programadora, ha tenido la oportunidad de aprender diversos lenguajes como C, Python y Java, cada uno con su propia lógica y estructura. Este año, además, se adentré en el mundo del desarrollo web con HTML y CSS. Aunque a simple vista pueden parecer herramientas básicas, descubrió que son fundamentales para entender cómo se construye y presenta la información en la web. Se ha dado cuenta de que cada lenguaje tiene algo que aportar, y que lo valioso está en saber cómo conectar los conocimientos y aplicar lo aprendido en distintos contextos. Esta diversidad de herramientas le ha permitido no solo ampliar su perspectiva, sino también reforzar su capacidad para adaptarme y resolver problemas desde distintos enfoques.</p>
            </div>
        </div>
        
        <!-- Sobre Sakura Bites -->
        <div>`
            <h2>Nuestra Historia</h2>
            <p>Sakura Bites nació de la pasión por compartir los sabores auténticos de Asia con nuestra comunidad. Como food truck, llevamos la experiencia culinaria directamente a ti, ofreciendo platos frescos y deliciosos inspirados en la cocina japonesa y coreana.</p>
            
            <h3>Nuestra Misión</h3>
            <p>Brindar una experiencia gastronómica única y accesible, combinando tradición e innovación en cada plato que servimos.</p>
            
            <h3>Nuestros Valores</h3>
            <ul>
                <li>Calidad en cada ingrediente</li>
                <li>Servicio rápido y amigable</li>
                <li>Innovación constante en nuestro menú</li>
                <li>Compromiso con la satisfacción del cliente</li>
            </ul>
        </div>
    </section>

    <footer>
        <nav>
            <a href="home.jsp">Inicio</a> |
            <a href="Nosotros.jsp">Sobre Nosotros</a> |
            <a href="Menu.jsp">Menú</a> |
            <a href="Logout.jsp">Logout</a>
        </nav>
        <p>&copy; 2025 Sakura Bites. Todos los derechos reservados.</p>
    </footer>
</body>
</html>