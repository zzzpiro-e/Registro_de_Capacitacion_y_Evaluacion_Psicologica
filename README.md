# 🧠 Sistema de Registro de Capacitación y Evaluación Psicológica (RCEP)

Bienvenido al repositorio oficial del **Proyecto Registro de Capacitación y Evaluación Psicológica**. Esta es una aplicación móvil desarrollada en Flutter diseñada para centralizar y agilizar la gestión de perfiles de trabajadores, su historial de capacitación y el manejo seguro de derivaciones e informes psicológicos.

Este proyecto se desarrolla en un entorno interdisciplinario mediante un equipo de desarrollo dedicado, coordinando requerimientos de Ingeniería de Software y validaciones de QA.

---

## ✨ Características Principales

* **Gestión de Fichas:** Creación, lectura y actualización de antecedentes personales y laborales de los trabajadores.
* **Control de Capacitaciones:** Visualización y filtrado de cursos según su estado (Pendiente, En curso, Completado).
* **Derivación Psicológica:** Flujo seguro para derivar trabajadores al departamento psicológico, incluyendo la carga y exportación de informes en formato PDF.
* **Seguridad y Roles:** Restricción de acceso a datos sensibles dependiendo del perfil del usuario (Administrador, Analista de RR.HH., Psicólogo Laboral).

---

## 🛠️ Stack Tecnológico

* **Framework:** Flutter
* **Lenguaje:** Dart
* **Entorno de Desarrollo:** VS Code
* **Control de Versiones:** Git / GitHub

---

## 🏗️ Arquitectura del Proyecto

El código fuente está estructurado bajo un enfoque modular para asegurar la escalabilidad y separación de responsabilidades:

* `/lib/app/`: Configuración global, inicialización y enrutamiento principal.
* `/lib/core/`: Elementos transversales (utilidades, temas visuales, manejo de red y configuraciones de entorno).
* `/lib/features/`: Módulos independientes con la lógica de negocio y vistas de cada funcionalidad.
* `/lib/shared/`: Componentes de interfaz de usuario reutilizables en toda la aplicación.

---

## 🌿 Flujo de Trabajo y Ramas

Para mantener la integridad del código, utilizamos el siguiente esquema de ramas:

* `main`: Rama de producción. Contiene únicamente código estable y validado.
* `develop`: Rama de integración principal. Aquí se unifica el trabajo del equipo de desarrollo.
* `Rama<Nombre>`: Ramas de características (features) o correcciones de bugs asignadas a cada desarrollador (ej. `RamaIan`).

---

## 👥 Equipo de Desarrollo

* **Marianela Pareja** - Product Owner
* **Benjamín Molina** - Scrum Master
* **Carlos Cerda** - Encargado de UX/UI
* **Ian Valenzuela** - Encargado de GIT
* **Gabriel Hidalgo** - Encargado de Integración Frontend
* **Tomás Sandoval** - Tech Lead Flutter
