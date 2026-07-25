import React from "react";
import { Panel, PanelHeading, Stack, Stepper } from "@tin-road/design-system";

export const InAPanel = () => (
	<Panel>
		<PanelHeading>Outfit the season</PanelHeading>
		<p style={{ margin: 0 }}>
			2 clay, 6 papyrus, 2 seals — 24 shekels, weighed out before the dew
			burned off.
		</p>
	</Panel>
);

export const TwoSections = () => (
	<Panel>
		<PanelHeading>The season purse</PanelHeading>
		<p style={{ margin: 0 }}>
			11 shekels of contract silver, counted twice and banked once.
		</p>
		<PanelHeading>Standing contracts</PanelHeading>
		<Stack>
			<Stepper label="Seals" hint="authenticate, or pay the courier"
				value={2} onChange={() => {}} />
		</Stack>
	</Panel>
);
