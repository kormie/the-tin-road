import React from "react";
import {
	Chronicle, SeasonHeading, Entry,
} from "@tin-road/design-system";

export const OpeningASeason = () => (
	<Chronicle>
		<SeasonHeading>The First Season</SeasonHeading>
		<Entry>In the first season of House Sapanu, Gamiradu took up the pen.</Entry>
		<Entry>
			House Yabninu advanced 30 shekels against the season's road — generously,
			promptly, and with the ledger of what it expected in return already open.
		</Entry>
	</Chronicle>
);

export const SeasonAfterSeason = () => (
	<Chronicle>
		<SeasonHeading>The Fourth Season</SeasonHeading>
		<Entry>
			The pen passed to Sinaranu. What Ushriya wrote remained; what Ushriya
			knew did not.
		</Entry>
		<SeasonHeading>The Fifth Season</SeasonHeading>
		<Entry>
			Abdimilku inherited the House, the Archive, and the Concord's memory of
			Sinaranu.
		</Entry>
	</Chronicle>
);
