#include <stdio.h>

//int main()
//{
//	{ // Ist natuerlich theoretisch unnoetig, aber kein Fehler per se
//		int n; %i; // Syntax: %i ist kein valider Variablenname und ; beendet die Deklaration
//		int x = 0; 
//		float y = 0; // Ist moeglich, aber semantisch wuerde es natuerlich hier mehr Sinn machen den float mit einem float zu initialisieren und keinen int->float cast zu forcieren
//
//		scanf("%d", &n); // Lexikalisch (?): scanf ist deprecated, Semantisch: return value wird ignoriert
//		for (%i = 1; x <= n; %i += 2) { // %i
//			{ // wieder unnoetig
//				x = ((x)) + %i; // Klammern unnoetig, %i
//				y++; // theoretisch korrekt, aber ich finde ++ auf float ist zumindest irreleitend
//			}
//		}
//		prindf("%d\n", y - 1); // Semantik: theoretisch korrekt, aber in Wirklichkeit wuerde man wohl erwarten, dass der Wert von y - 1 (wieder mal float/int Probleme) auch tatsaechlich angezeigt wird
//		return 0;
//	}
//}

int main()
{
	{
		int n, i;
		int x = 0;
		float y = 0;

		scanf("%d", &n);
		for (i = 1; x <= n; i += 2) {
			{
				x = ((x)) + i;
				y++;
			}
		}
		printf("%f\n", y - 1);
		return 0;
	}
}