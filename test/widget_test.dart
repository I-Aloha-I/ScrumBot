import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto1/crear_historia_page.dart'; // asegúrate de que el nombre del paquete sea correcto

void main() {
  testWidgets('Mostrar y validar formulario de historia', (WidgetTester tester) async {
    // Montamos CrearHistoriaPage dentro de un MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        home: CrearHistoriaPage(),
      ),
    );

    // Esperamos a que se construya
    await tester.pumpAndSettle();

    // Verificamos que el campo Título esté presente
    expect(find.widgetWithText(TextFormField, 'Título'), findsOneWidget);

    // Tocamos el botón Guardar sin llenar el formulario
    await tester.tap(find.text('Guardar Historia'));
    await tester.pump(); // Dispara la validación

    // Verificamos que aparezcan mensajes de error por campos vacíos
    expect(find.text('Este campo es obligatorio'), findsWidgets);
  });
}
