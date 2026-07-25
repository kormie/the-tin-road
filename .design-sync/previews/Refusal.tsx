import React from "react";
import { Refusal, Panel, PanelHeading, Button, Stack } from "@tin-road/design-system";

export const TheWorldSaysNo = () => (
	<Refusal>
		No courier goes: it takes a seal, 4 media, and something written.
	</Refusal>
);

export const PresentEvenWhenEmpty = () => (
	<Stack>
		<Panel>
			<PanelHeading>Before the attempt</PanelHeading>
			<Button tone="danger">Send the ledger home by courier</Button>
			<Refusal />
		</Panel>
		<Panel>
			<PanelHeading>After the attempt</PanelHeading>
			<Button tone="danger">Send the ledger home by courier</Button>
			<Refusal>
				No courier goes: the last seal went on the survey of leg 2.
			</Refusal>
		</Panel>
	</Stack>
);
