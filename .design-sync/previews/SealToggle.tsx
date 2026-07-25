import React from "react";
import { SealToggle, Stack, Panel, PanelHeading, Button } from "@tin-road/design-system";

export const Unsealed = () => (
	<SealToggle checked={false} onChange={() => {}}>
		Seal what is written next
	</SealToggle>
);

export const Sealed = () => (
	<SealToggle checked onChange={() => {}}>
		Seal what is written next — one of 2 seals goes with it
	</SealToggle>
);

export const AtTheWritingDesk = () => (
	<Panel major>
		<PanelHeading>The pen</PanelHeading>
		<Stack>
			<SealToggle checked onChange={() => {}}>
				Seal what is written next
			</SealToggle>
			<Button tone="primary">Survey the road as far as the Salt Marsh</Button>
		</Stack>
	</Panel>
);
