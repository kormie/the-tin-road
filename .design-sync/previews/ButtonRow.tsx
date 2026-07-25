import React from "react";
import {
	ButtonRow, Button, Panel, PanelHeading, Stack,
} from "@tin-road/design-system";

export const FourEntryTypes = () => (
	<ButtonRow>
		<Button>Note</Button>
		<Button>Record</Button>
		<Button>Survey</Button>
		<Button>Treatise</Button>
	</ButtonRow>
);

export const TwoActs = () => (
	<ButtonRow>
		<Button tone="primary">Buy the pack and take the road</Button>
		<Button>Begin the next season</Button>
	</ButtonRow>
);

export const InThePanel = () => (
	<Panel major>
		<PanelHeading>The road</PanelHeading>
		<Stack>
			<Button tone="primary">Travel to the next node</Button>
			<ButtonRow>
				<Button>Note</Button>
				<Button>Record</Button>
				<Button>Survey</Button>
				<Button>Treatise</Button>
			</ButtonRow>
			<Button tone="danger">Send the ledger home by courier</Button>
		</Stack>
	</Panel>
);
