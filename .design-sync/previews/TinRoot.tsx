import React from "react";
import {
	TinRoot, Title, MeanderRule, Chronicle, SeasonHeading, Entry, Colophon,
	Panel, PanelHeading, StatusStrip, Button, Stack,
} from "@tin-road/design-system";

export const ThePageGround = () => (
	<TinRoot>
		<Title>THE TIN ROAD</Title>
		<MeanderRule />
		<Chronicle>
			<Colophon>Seed 101. Written as it happens.</Colophon>
			<SeasonHeading>The First Season</SeasonHeading>
			<Entry>In the first season of House Sapanu, Gamiradu took up the pen.</Entry>
			<Entry>
				At the guild hall of Ugarit, Gamiradu bought the season's pack: 2 clay,
				6 papyrus, 2 seals — 24 shekels, weighed out before the dew burned off.
			</Entry>
		</Chronicle>
	</TinRoot>
);

export const GroundUnderTheTools = () => (
	<TinRoot>
		<Stack>
			<StatusStrip>
				Gamiradu at the Salt Marsh — day 4 — 31 light — 2 clay, 2 papyrus,
				2 seals — purse 2 — next step 2 light
			</StatusStrip>
			<Panel major>
				<PanelHeading>The road</PanelHeading>
				<Stack>
					<Button tone="primary">Travel to the next node</Button>
					<Button tone="danger">Send the ledger home by courier</Button>
				</Stack>
			</Panel>
		</Stack>
	</TinRoot>
);
