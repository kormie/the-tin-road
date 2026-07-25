import React from "react";
import { Chronicle, SeasonHeading, Entry, Colophon } from "@tin-road/design-system";

export const AGrowingBook = () => (
	<Chronicle>
		<Colophon>Seed 101. Written as it happens.</Colophon>
		<SeasonHeading>The First Season</SeasonHeading>
		<Entry>In the first season of House Sapanu, Gamiradu took up the pen.</Entry>
		<Entry>
			House Yabninu advanced 30 shekels against the season's road — generously,
			promptly, and with the ledger of what it expected in return already open.
		</Entry>
		<Entry>
			The water at the Salt Marsh took its census: 4 sheets of papyrus came out
			pulp. The clay came out streaked but legible.
		</Entry>
	</Chronicle>
);

export const ASeasonTurns = () => (
	<Chronicle>
		<SeasonHeading>The Second Season</SeasonHeading>
		<Entry>
			The pen passed to Anat. What Gamiradu wrote remained; what Gamiradu knew
			did not.
		</Entry>
		<Entry>
			While the House slept, a caravan walked the Ugarit road on its own and
			came home with 362 shekels, weighed. The road remembered; it had been
			written down.
		</Entry>
	</Chronicle>
);
