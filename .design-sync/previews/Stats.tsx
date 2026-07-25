import React from "react";
import { Stats, Stat, Panel, PanelHeading } from "@tin-road/design-system";

export const OutfitFigures = () => (
	<Stats>
		<Stat label="cost" value="24 shekels" />
		<Stat label="bulk" value="12 of 16" />
		<Stat label="treasury" value="0 + 30 advance" />
	</Stats>
);

export const TheBeltCount = () => (
	<Stats>
		<Stat label="daylight" value="31 of 40" />
		<Stat label="clay" value="2" />
		<Stat label="papyrus" value="3" />
		<Stat label="seals" value="1" />
		<Stat label="purse" value="8 shekels" />
		<Stat label="entries" value="2" />
		<Stat label="archive" value="leg 2 sealed" />
	</Stats>
);

export const TheHouseAccounts = () => (
	<Panel>
		<PanelHeading>The House accounts</PanelHeading>
		<Stats>
			<Stat label="treasury" value="358 shekels" />
			<Stat label="standing order" value="100 to the guild scribes" />
			<Stat label="drover bond" value="60 at the gate" />
		</Stats>
	</Panel>
);
