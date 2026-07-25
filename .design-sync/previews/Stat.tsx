import React from "react";
import { Stats, Stat } from "@tin-road/design-system";

export const OneFigure = () => (
	<Stats>
		<Stat label="daylight" value="31 of 40" />
	</Stats>
);

export const AmongItsRow = () => (
	<Stats>
		<Stat label="cost" value="24 shekels" />
		<Stat label="bulk" value="12 of 16" />
		<Stat label="treasury" value="0 + 30 advance" />
	</Stats>
);
