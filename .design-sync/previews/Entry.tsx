import React from "react";
import {
	Chronicle, SeasonHeading, Entry,
} from "@tin-road/design-system";

export const EntriesInTheBook = () => (
	<Chronicle>
		<SeasonHeading>The Second Season</SeasonHeading>
		<Entry>The Salt Marsh passed beneath the caravan's feet and asked for nothing.</Entry>
		<Entry>
			Something went wrong at the Rival Sail in the ordinary way, and it cost
			a clay tablet.
		</Entry>
		<Entry>
			The Drowned Shrine took its toll in patience — 2 days of light gone to
			waiting.
		</Entry>
	</Chronicle>
);

export const ALongEntry = () => (
	<Chronicle>
		<Entry>
			The purse came up short at the Rival Sail, and House Urtenu took its
			remedy: the purse emptied, two of media seized against the debt, and the
			consignment torn up. The ledger records it without editorial, which is
			the only mercy a ledger has.
		</Entry>
	</Chronicle>
);
