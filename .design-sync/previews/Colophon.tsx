import React from "react";
import {
	Chronicle, SeasonHeading, Entry, Colophon,
} from "@tin-road/design-system";

export const SeedLine = () => (
	<Chronicle>
		<Colophon>Seed 101. Written as it happens.</Colophon>
		<SeasonHeading>The First Season</SeasonHeading>
		<Entry>In the first season of House Sapanu, Gamiradu took up the pen.</Entry>
	</Chronicle>
);

export const CompilersAttribution = () => (
	<Chronicle>
		<SeasonHeading>The Tenth Season</SeasonHeading>
		<Entry>Ugarit received its scribe back. 0 entries came home in the bags.</Entry>
		<Entry>
			The road purse came home: 16 shekels of contract silver, banked into the
			House accounts.
		</Entry>
		<Colophon>As compiled from the House archive. Seed 101.</Colophon>
	</Chronicle>
);
