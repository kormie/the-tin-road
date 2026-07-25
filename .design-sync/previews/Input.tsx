import React from "react";
import { Input, Panel, PanelHeading, Stack, Button } from "@tin-road/design-system";

export const WithAValue = () => (
	<Input defaultValue="101" aria-label="seed" />
);

export const PlaceholderOnly = () => (
	<Input placeholder="seed" aria-label="seed" />
);

export const InThePanel = () => (
	<Panel>
		<PanelHeading>Begin a chronicle</PanelHeading>
		<Stack>
			<Input placeholder="seed" defaultValue="101" aria-label="seed" />
			<Button tone="primary" inline>Take up the pen</Button>
		</Stack>
	</Panel>
);
