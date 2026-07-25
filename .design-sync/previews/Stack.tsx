import React from "react";
import {
	Stack, Button, StatusStrip, Panel, PanelHeading, Refusal, Input,
} from "@tin-road/design-system";

export const ControlsInFlow = () => (
	<Stack>
		<Button tone="primary">Travel to the next node</Button>
		<Button>Buy a seal at the guild hall</Button>
		<Button tone="danger">Send the ledger home by courier</Button>
		<Input placeholder="seed" defaultValue="101" />
	</Stack>
);

export const PanelsInFlow = () => (
	<Stack>
		<StatusStrip>
			Gamiradu at the Salt Marsh — day 4 — 31 light — 2 clay, 2 papyrus,
			2 seals — purse 2 — next step 2 light
		</StatusStrip>
		<Panel major>
			<PanelHeading>The road</PanelHeading>
			<Button tone="primary">Travel to the next node</Button>
			<Refusal>
				No courier goes: it takes a seal, 4 media, and something written.
			</Refusal>
		</Panel>
		<Panel>
			<PanelHeading>The desk</PanelHeading>
			<Button>Post a standing order (assign the caravan)</Button>
		</Panel>
	</Stack>
);
