import React from "react";
import {
	Panel, PanelHeading, Stack, Button, ButtonRow, SealToggle, Refusal,
} from "@tin-road/design-system";

export const APanel = () => (
	<Panel>
		<PanelHeading>The archive</PanelHeading>
		<p style={{ margin: 0 }}>
			Three entries the House cannot forget, and one survey filed as hearsay,
			which is what an unsealed truth is.
		</p>
	</Panel>
);

export const MajorContour = () => (
	<Stack>
		<Panel major>
			<PanelHeading>The road</PanelHeading>
			<p style={{ margin: 0 }}>The view's major piece earns the heavy line.</p>
		</Panel>
		<Panel>
			<PanelHeading>Outfit the season</PanelHeading>
			<p style={{ margin: 0 }}>Everything else keeps the ordinary contour.</p>
		</Panel>
	</Stack>
);

export const TheRoadPanel = () => (
	<Panel major>
		<PanelHeading>The road</PanelHeading>
		<Stack>
			<Button tone="primary">Travel to the next node</Button>
			<SealToggle checked={false} onChange={() => {}}>
				Seal what is written next
			</SealToggle>
			<ButtonRow>
				<Button>Note</Button>
				<Button>Record</Button>
				<Button>Survey</Button>
			</ButtonRow>
			<Button tone="danger">Send the ledger home by courier</Button>
		</Stack>
		<Refusal>
			No courier goes: it takes a seal, 4 media, and something written.
		</Refusal>
	</Panel>
);
