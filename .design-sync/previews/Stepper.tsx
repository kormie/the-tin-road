import React from "react";
import { Stepper, Stack, Panel, PanelHeading, Stats, Stat } from "@tin-road/design-system";

export const WithHint = () => (
	<Stepper label="Papyrus" hint="light, ruined by water"
		value={6} onChange={() => {}} />
);

export const WithoutHint = () => (
	<Stepper label="Seals" value={2} onChange={() => {}} />
);

export const TheOutfitDesk = () => (
	<Panel>
		<PanelHeading>Outfit the season</PanelHeading>
		<Stack>
			<Stepper label="Clay" hint="cheap, heavy, survives water"
				value={2} onChange={() => {}} />
			<Stepper label="Papyrus" hint="light, ruined by water"
				value={6} onChange={() => {}} />
			<Stepper label="Seals" hint="authenticate, or pay the courier"
				value={2} onChange={() => {}} />
			<Stats>
				<Stat label="cost" value="24 shekels" />
				<Stat label="bulk" value="12 of 16" />
				<Stat label="treasury" value="0 + 30 advance" />
			</Stats>
		</Stack>
	</Panel>
);
