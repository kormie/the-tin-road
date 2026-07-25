import React from "react";
import { StatusStrip, Stack, Panel, PanelHeading, Button } from "@tin-road/design-system";

export const OnTheRoad = () => (
	<StatusStrip>
		Gamiradu at the Salt Marsh — day 4 — 31 light — 2 clay, 6 papyrus,
		2 seals — purse 2 — next step 2 light
	</StatusStrip>
);

export const AtTheGate = () => (
	<StatusStrip>
		Milkuyaton at Ugarit — the season not yet begun — treasury 41 shekels —
		archive holds 3 entries
	</StatusStrip>
);

export const AboveTheTool = () => (
	<Stack>
		<StatusStrip>
			Ibiranu at the Drowned Shrine — day 5 — 22 light — 2 clay, 3 papyrus,
			1 seal — purse 8 — next step 3 light
		</StatusStrip>
		<Panel major>
			<PanelHeading>The road</PanelHeading>
			<Button tone="primary">Travel to the next node</Button>
		</Panel>
	</Stack>
);
